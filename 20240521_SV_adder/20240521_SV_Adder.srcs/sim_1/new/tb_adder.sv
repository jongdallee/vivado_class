`timescale 1ns / 1ps


//interface
interface adder_intf;
    logic       clk;
    logic       reset;
    logic       valid;
    logic [3:0] a;
    logic [3:0] b;
    logic [3:0] sum;
    logic       carry;
endinterface  //adder_intf

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

//transaction 만들기
class transaction;
    rand logic [3:0] a;  //랜덤값을 생성, 신호값
    rand logic [3:0] b;  //랜덤값을 생성, 신호값
    logic      [3:0] sum;
    logic            carry;
    // rand logic        valid; //랜덤값을 생성, 신호값

    //기본적인 것에서 추가
    task display(string name);
        $display("[%s] a:%d, b:%d, carry:%d, sum:%d", name, a, b, carry, sum);  
        //stirg값을 제공해줌
    endtask  //$display(string name);
    //valid:%d , , valid 
endclass  //transcartion

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

//generator 만들기 (생성해주는 것)
//rand값 만드는 과정임
class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    event genNextEvent1; //이벤트 제작

    function new();
        tr = new(); //실체 객체가 아니라 new로 실제 trascartion 객체화
    endfunction  //new()

    task run();
        repeat (1000) begin  //begin end를 1000번 반복하겠다
            assert (tr.randomize())
            else $error("tr.randomize() error!");  
            //display 보다 강력한 출력
            gen2drv_mbox.put(tr);  //핸들러의 값
            tr.display("GEN");
            //wait(genNextEvent1.triggered); //이벤트 대기
            @(genNextEvent1); //이벤트 대기
        end
    endtask  // delay없이 시작하자마자 10번 돌아 나옴
endclass  //generate

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

//driver 만들기
class driver;
    virtual adder_intf adder_if1; //가상인터페이스
    mailbox #(transaction) gen2drv_mbox;
    transaction trans;
    //event genNextEvent2; //이벤트 제작
    event monNextEvent2;

    function new(virtual adder_intf adder_if2); //멤버함수느낌
        this.adder_if1 = adder_if2; //하나 카피되는 느낌
    endfunction  //new()

    task reset();
        adder_if1.a <= 0;
        adder_if1.b <= 0;
        adder_if1.valid <= 1'b0;
        adder_if1.reset <= 1'b1;
        repeat (5) @(adder_if1.clk);
        adder_if1.reset <= 1'b0;  //reset신호를 주는 방법
    endtask  //

    task run();
        forever begin //generartor 에서 생성한 값을 전달해야함 어떻게?
            gen2drv_mbox.get(trans);//
            adder_if1.a     <= trans.a;
            adder_if1.b     <= trans.b;
            adder_if1.valid <= 1'b1;
            trans.display("DRV");
            @(posedge adder_if1.clk);
            adder_if1.valid <= 1'b0;
            @(posedge adder_if1.clk); //2번 clk이 되면 출력이 나옴          
            -> monNextEvent2;
            //-> genNextEvent2;//이벤트 트리거링
       
        end
    endtask
endclass  //driver

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

//monitor 만들기
class monitor;
    virtual adder_intf adder_if3;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;
    event monNextEvent1; //계속돌아서 이벤트

    function new(virtual adder_intf adder_if2); //adder 인터페이스 만들기
        this.adder_if3 = adder_if2;
        trans = new(); //생성자
    endfunction //new()

    task run();
      forever begin
        @(monNextEvent1);//계속 돌기에 만듬
        trans.a       = adder_if3.a; 
        trans.b       = adder_if3.b;
        trans.sum     = adder_if3.sum;//결과값 
        trans.carry   = adder_if3.carry;
        mon2scb_mbox.put(trans);//메일박스에 put
        trans.display("MON");
      end
    endtask
endclass //monitor
   
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

class scoreboard; //전광판 역할임(현재상태 및 결과물 확인 후 판단)
//(sw값이랑 hw값을 비교) sw값은 맞다고 믿음, hw의 결과값을 test
    mailbox #(transaction)mon2scb_mbox;
    transaction trans;
    event genNextEvent2; //이벤트 제작
      
     int total_cnt, pass_cnt, fail_cnt;


 
    function new();
    total_cnt = 0; 
    pass_cnt  = 0;
    fail_cnt  = 0;
    endfunction //new()

    task run();
      forever begin
        mon2scb_mbox.get(trans);
        trans.display("SCB");
        if((trans.a + trans.b) == {trans.carry, trans.sum}) begin 
            //(trans.a + trans.b) <- 식을 reference model, 해당 값을 golden reference
            $display(" --> PASS! %d + %d = %d",trans.a, trans.b, {trans.carry, trans.sum});
            pass_cnt++;
        end
        else begin
            $display(" --> FAIL! %d + %d = %d",trans.a, trans.b, {trans.carry, trans.sum});
            fail_cnt++;
        end
        total_cnt++;
        ->genNextEvent2; //이벤트 제작
      end
    endtask
endclass //scoreboard

//interface는 물리적인거라 필요없음

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

//Event연결이 어떻게 됨???? 밑에서 함
module tb_adder ();


    adder_intf adder_interface(); //인터페이스에 대한 실체화
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    event genNextEvent; //이벤트 연결 변수
    event monNextEvent;
    //검증하고 싶은것 
    //원래는 reg,wire로 했었음
    
    mailbox #(transaction)gen2drv_mbox;
    mailbox #(transaction)mon2scb_mbox;

adder dut(
    .clk(adder_interface.clk), //adder in 점에 멤버로 있는 clk를 사용하겠다.  // 물리적 선언
    .reset(adder_interface.reset),
    .valid(adder_interface.valid),
    .a(adder_interface.a), //tr.a
    .b(adder_interface.b),
    .sum(adder_interface.sum),
    .carry(adder_interface.carry)
    );

always #5 adder_interface.clk = ~adder_interface.clk;

    initial begin //초기값 설정
       adder_interface.clk     = 1'b0;
       adder_interface.reset   = 1'b1;
    end

    initial begin
        gen2drv_mbox = new();
        mon2scb_mbox = new();

        gen          = new();         //생성자 new() 
        drv          = new(adder_interface); //물리적인 인터페이스 값
        mon          = new(adder_interface); //물리적인 인터페이스 값
        scb          = new();

        gen.genNextEvent1 =genNextEvent;
        scb.genNextEvent2 =genNextEvent;
        //drv.genNextEvent2 =genNextEvent;
        
        mon.monNextEvent1 =monNextEvent;
        drv.monNextEvent2 =monNextEvent;

        gen.gen2drv_mbox = gen2drv_mbox;
        drv.gen2drv_mbox = gen2drv_mbox;
        mon.mon2scb_mbox = mon2scb_mbox;
        scb.mon2scb_mbox = mon2scb_mbox;


        drv.reset();//드라이버 리셋 실행
        
        fork 
        gen.run(); //process 독립적 run 실행
        drv.run(); //process독립적 run 실행
        mon.run(); //process독립적 run 실행
        scb.run(); //process독립적 run 실행
        join_any

        $display("============================");
        $display("===     Final Report     ===");
        $display("============================");
        $display("Total Test : %d", scb.total_cnt);
        $display("Pass Count : %d", scb.pass_cnt);
        $display("Fail Count : %d", scb.fail_cnt);
        $display("============================");
        $display("test bench is finished!");
        #10 $finish;
    end
endmodule
