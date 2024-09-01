`timescale 1ns / 1ps

////////////////////////// Interface //////////////////////////

interface uart_interface;
    logic        clk;
    logic        wr_en;
    logic [9:0]  addr;
    logic [7:0]  wdata;
    logic [7:0]  rdata;
endinterface

////////////////////////// Transaction //////////////////////////

class transaction;
    rand bit          wr_en; 
    randc bit  [9:0]  addr; 
    randc bit  [7:0]  wdata;
    bit        [7:0]  rdata;

    task display(string name);
        $display("[%s] wr_en: %x, addr: %x, wdata: %x, rdata: %x", name, wr_en, addr,wdata,rdata);
    endtask

    constraint c_addr  {addr inside {[10:19]};}
    constraint c_wdata1{wdata < 100;}
    constraint c_wdata2{wdata > 10;}
    constraint c_wr_en {wr_en dist{0:/60,1:/40};}
endclass

////////////////////////// Generator //////////////////////////

class generator;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    event gen_next_event;

    function new(mailbox#(transaction) gen2drv_mbox, event gen_next_event);
        this.gen2drv_mbox   = gen2drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction

    task run(int count);
        repeat (count) begin
            trans = new();
            assert (trans.randomize())
            else $error("[GEN] trans.randomize() error!");
            gen2drv_mbox.put(trans);
            trans.display("GEN");
            @(gen_next_event);
        end
    endtask
endclass

////////////////////////// Driver //////////////////////////

class driver;
    transaction trans;
    mailbox #(transaction) gen2drv_mbox;
    virtual uart_interface uart_intf;

    function new(virtual uart_interface uart_intf, mailbox#(transaction) gen2drv_mbox);
        this.uart_intf = uart_intf;
        this.gen2drv_mbox = gen2drv_mbox;
    endfunction

    task reset();
        uart_intf.wr_en  <= 1'b0;
        uart_intf.addr   <= 0;
        uart_intf.wdata  <= 0;
        repeat (5) @(posedge uart_intf.clk);
    endtask

    task run();
        forever begin
            gen2drv_mbox.get(trans); 
            uart_intf.wr_en <= trans.wr_en;
            uart_intf.addr  <= trans.addr;
            uart_intf.wdata <= trans.wdata;
            trans.display("DRV");
            @(posedge uart_intf.clk);
        end
    endtask
endclass

////////////////////////// Monitor //////////////////////////

class monitor;
    virtual uart_interface uart_intf;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;

    function new(virtual uart_interface uart_intf, mailbox#(transaction) mon2scb_mbox);
        this.uart_intf = uart_intf;
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction

    task run();
        forever begin
            trans = new();
            @(posedge uart_intf.clk);
            trans.wr_en = uart_intf.wr_en;  
            trans.addr = uart_intf.addr;
            trans.wdata = uart_intf.wdata;
            trans.rdata = uart_intf.rdata;
            trans.display("MON");
            mon2scb_mbox.put(trans);
        end
    endtask
endclass

////////////////////////// Scoreboard //////////////////////////

class scoreboard;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;
    event gen_next_event;

    int total_cnt, pass_cnt, fail_cnt,write_cnt;
    logic [7:0] mem[0:2**10-1];

    function new(mailbox#(transaction) mon2scb_mbox, event gen_next_event);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_event = gen_next_event;
        total_cnt = 0;
        pass_cnt = 0;
        fail_cnt = 0;
        write_cnt = 0;

      for (int i=0; i<2**10; i++)begin
        mem[i] = 0;
      end

    endfunction

    task run();
        forever begin
            mon2scb_mbox.get(trans);
            trans.display("SCB");
            if(trans.wr_en) begin
              if(mem[trans.addr] == trans.rdata) begin
                 $display("-->READ PASS! mem[%x] == %x",mem[trans.addr], trans.rdata);
                 pass_cnt++;
                end else begin
                 $display("-->READ FAIL! mem[%x] == %x",mem[trans.addr], trans.rdata);
                 fail_cnt++;
                end
            end else begin
              mem[trans.addr] = trans.wdata;
              $display("--> WRITE! mem[%x] == %x",trans.addr, trans.wdata);
              write_cnt++;
            end 
               total_cnt++;
              ->gen_next_event;
        end
    endtask
endclass

////////////////////////// Environment //////////////////////////

class environment;
     generator gen;
     driver     drv;
     monitor    mon;
     scoreboard scb;

     event gen_next_event;

     mailbox #(transaction) gen2drv_mbox;
     mailbox #(transaction) mon2scb_mbox;

     function new(virtual uart_interface uart_intf);
     gen2drv_mbox = new();
     mon2scb_mbox = new();

     gen = new(gen2drv_mbox,gen_next_event);
     drv = new(uart_intf, gen2drv_mbox);
     mon = new(uart_intf, mon2scb_mbox);
     scb = new(mon2scb_mbox, gen_next_event);
     endfunction
     
     task report();
        $display("=============================");
        $display("===     Final  Report     ===");
        $display("=============================");
        $display("= Total Test  : %d =", scb.total_cnt);
        $display("= Pass Count  : %d =", scb.pass_cnt);
        $display("= Fail Count  : %d =", scb.fail_cnt);
        $display("= WRITE Count : %d =", scb.write_cnt);
        $display("=============================");
        $display("== test bench is finished! ==");
     endtask

     task pre_run();
         drv.reset;
     endtask

     task run();
       fork
        gen.run(100);
        drv.run();
        mon.run();
        scb.run();
       join_any
       report();
       #10 $finish;
     endtask

     task run_test();
          pre_run();
          run();
     endtask
endclass
////////////////////////// Test Bench //////////////////////////
module tb_uart ();

    uart_interface uart_intf();
    environment env(uart_intf);


    uart dut(
        .clk(uart_intf.clk),
        .address(uart_intf.addr),
        .wdata(uart_intf.wdata),
        .wr_en(uart_intf.wr_en),
        .rdata(uart_intf.rdata)
    );

    always #5 uart_intf.clk = ~uart_intf.clk;

    initial begin
        uart_intf.clk = 0;
    end

    initial begin
        env.run_test();
    end

endmodule