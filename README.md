# Datapath

![alt text](https://github.com/ChiaYi-LIN/RISCV-pipelined-CPU-with-cache/blob/master/Datapath.png)


# Development Environment

- OS: Windows 10
- Compiler: iverilog
- IDE: VScode editor

# Modules Explanation

### Control.v

Control module 讀入 7-bit OPcode、1-bit NoOp，輸出 2-bit ALUOp，以及分別為 1-bit 的 ALUSrc、RegWrite、MemtoReg、MemRead、MemWrite、Branch 作為 Control Signals，以下為各訊號設定規則：

- NoOp: 假如輸入的 NoOp 是 "1"，代表要取消所有 Control Signals，實作上只需要確保 RegWrite、MemRead、MemWrite 都設成 "0" 即可，未來傳到後面 stages 的時候就不會修改到 Register Files 或 Data Memory
- ALUOp: 這邊沒有完全依照課本的編碼，而是觀察 machine code 的格式歸納出來的規則；如果 OPcode 對應的是一般算術運算 (R-Type)，則設定成 "10"，如果是 immediate arithmetic 或 lw 則設成 "11"，若是 sw 則設成 "00"，而 beq 可以忽略因為在 ID stage 就會決定是否做分支，不需要 ALUOp
- ALUSrc: 對於 R-Type、beq 運算將訊號設為 "0"，因為這類運算的 ALU second input 是來自 Read Register Data 2；而 immediate arithmetic、lw 和 sw 指令則將訊號設為 "1"，因為這類運算的 ALU second input 是來自 ImmGen 的輸出
- RegWrite: 對於需要寫入 Register Files 的指令 (R-Type、immediate arithmetic、lw) 將訊號設成 "1"，其他的則是 "0"
- MemtoReg: 在需要寫入 Register Files 的指令中，因為 R-Type、immediate arithmetic 是將 ALU 運算的結果寫入，故將訊號設成 "0"，而 lw 則是要把從 Data Memory 讀出來的資料寫入，因此訊號設成 "1"，其他指令的情況則可以忽略
- MemRead: 對於需要從 Data Memory 讀取資料的 lw 指令，將訊號設成 "1"，其他的則是 "0"
- MemWrite: 對於需要寫入 Data Memory 的 sw 指令，將訊號設成 "1"，其他的則是 "0"
- Branch: 對於需要做分支的 beq 指令，將訊號設成 "1"，其他的則是 "0"

### ALU_Control.v

ALU_Control module 讀入 10-bit function code (包含 funct7 和 funct3) 和 2-bit ALUOp signal，輸出 4-bit ALUCtrl 控制 ALU 運算。由於 spec 中要求的總共有 11 種不同運算，因此 ALUCtrl 最多需要 4 bits 即可處理每一種指令，設定如下：

| Operation | ALUCtrl |
| --- | --- |
| and | 0000 |
| xor | 0001 |
| sll | 0010 |
| add | 0011 |
| sub | 0100 |
| mul | 0101 |
| addi, lw | 0110 |
| srai | 0111 |
| sw | 1000 |
| beq | don't care (因為在 ID stage 決定) |

### Pipeline_Registers.v

是用來把 IF、ID、EX、MEM、WB 五個 stages 做區隔的 module，須確保 4 個 Pipeline Registers 的output 都是 reg，且只有 clock positive edge 時才允許更改

- **Challenge**

除了將所有 Pipeline Registers 的 input、output 接起來，我在實作上遇到的困難是在 load use data hazard 發生的時候，原本在 ID stage 的指令沒有如預期停住，後來發現是因為 IF/ID Pipeline Register 的 procedure block 沒有加上要在非 stall 情況才能更改對應 reg 的條件

### Forwarding_Unit.v

先檢查 EX stage 是否跟 MEM stage 有 data hazard 的問題，若有，設定對應的 forward signal 為 "10"；否則，檢查 EX stage 有沒有跟 WB stage 發生 data hazard，若有，設定對應 forward signal 為 "01"；否則設定為 "00"；之後 4-to-1 Mux 對根據這些訊號讓對應的資料通過，成為 ALU 的 input 或 ALUSrc Mux 的 input

### Hazard_Detection_Unit.v

為了避免 load use data hazard，需在這裡偵測，如果 hazard 發生需做到三件事：

1. NoOp = "1"，因為會讓 Control Signal 的 RegWrite、MemRead、MemWrite 都設成 "0" ，因此下一個 cycle EX 中的 instruction 會相當於 No-Op
2. Stall = "1"，現在在 ID stage 的指令在下一個 cycle 時要停留在原處
3. PCWrite = "0"，PC 不能被更改，必須繼續 fetch 原本的指令

如果沒有 load use date hazard，則都設成相反訊號，pipeline 會如平常運作

### testbench.v

須在 initial block 中為 Pipeline Registers 設定初始值，基本上是 IF/ID 的初始 instruction 為 No-Op，其他的 Pipeline Registers 如果有 RegWrite、MemRead、MemWrite 就設成 "0"

- **Challenge**

如果只有做以上的 initialize，會發現在測試時，第二個 R-Type 指令會出錯，後來發現是 Main Control 的 RegWrite 也要設成 "0"，否則預設會是 "x"，導致不能正常讀取 Register Files

### ALU.v

ALU module 讀入兩個 32-bit data "data_1_i" 和 "data_2_i" 以及 4-bit ALUCtrl，輸出是 32-bit 運算結果 "data_o" 。利用 ALUCtrl 可直接對兩個 data 執行對應運算，計算出結果存在 data_o

- **Challenge**

測試時發現上次作業沒有處理好 srai 在面對負數的情況，一旦對 data1_i 直接做 ">>>" 會發生錯誤，正確做法應是對 $signed(data1_i) 做 ">>>"

### Adder.v

Adder module 讀入兩個 32-bit data "data1_in" 和 "data2_in"，輸出運算結果 "data_o" 為兩個 data 的加總

### MUX32.v

MUX32 module 是一個 2-to-1 mux，讀入兩個 32-bit data "data1_in" 和 "data2_in" 以及控制訊號 "select_i"，輸出 "data_o" 為根據訊號選擇的其中一個 data。 其中，若 select_i= 0，則 data_o = data1_in，否則 data_o = data2_in

### MUX32_4_to_1.v

跟 MUX32 類似，只是從 2-to-1 變成 4-to-1，會根據 2-bit select 訊號輸出對應結果

### Equal.v

用來在 branch 指令做比較，如果 read_data_1 和 read_data_2 相同會輸出 "1"，反之為 "0"

### Flush_And.v

當 Branch 訊號為 "1" 且 Equal 的輸出訊號也是 "1"，代表確定要做分支，將輸出設為 "1"

### Shift_Left_1.v

因為 Branch 的 addressing mode 是 PC-relative，所以須將對應 bit 從 ImmGen 取出後往左移一位才是真正要和目前 PC 做相加的相對位址，輸出則是 branch address

### dcache_controller.v

cache controller 負責在 CPU 發出 load/store 指令的時候辨別是 cache hit 或 cache miss，然後根據spec 中要求的 write back 和 write allocate policy，controller 要負責 CPU 和 Data Memory 之間的互動，因為 controller 會有幾個不同 state，其中的 state 包括：

- STATE_IDLE: 只要 CPU 沒有發出 Data Memory request 或是每個 request 都 hit，就會一直停留在這個 state；反之，一旦有一個 request 是 miss，就會轉換到 STATE_MISS
- STATE_MISS: 在這個 state 中，controller 要分辨目前 cache 中的資料是否有被修改過，即是否 dirty，因為如果 dirty 的話根據 write back policy 在處理 miss 之前應該把資料寫回 Data Memory，因此，在 dirty 的情況下，state 應該要轉換成 STATE_WRITEBACK，同時設定 mem_enable=1、mem_write=1、write_back=1；反之，如果資料不是 dirty，就可以放心的從 Data Memory 取資料放進 cache 中，所以 state 轉換成 STATE_READMISS，同時設定 mem_enable=1
- STATE_WRITEBACK: 在這個 state 中，需要等待 Data Memory 的 ack=1 訊號才代表完成，所以在這之前一律停留在原本的 state，直到 write back 完成，就可以接著去處理 read miss，因此 state 轉換成 STATE_READMISS 並且設定 mem_enable=1，同時因為 write back 完成了所以設定 mem_write=0、write_back=0
- STATE_READMISS: 在這個 state 中，也是要等待 Data Memory 的 ack=1 訊號才代表完成，所以在這之前一樣要停留在原本 state，直到 ack=1 代表取得 Data Memory 的資料了，只要把資料搬進 cache 中，即可解決 read miss ，因此設定 mem_enable=0、mem_write=0、cache_write=1，然後 state 轉換成 STATE_READMISSOK
- STATE_READMISSOK: 因為資料已經搬進 cache，所以只需要讓 cache_write=0，state 就可以直接回到 STATE_IDLE

### dcache_sram.v

為了加上 LRU replacement policy，需要額外宣告 16*2 (因為 2-way associative) 的 reg ，使得在每個 set 中最近使用的 block 給予 value 1，比較久以前用的則給予 value 0；另外再宣告兩個 wire hit_0、hit_1，用來代表一個 set 中 0、1 entry 有沒有 hit，如果有其中一個 hit 則 hit_o=1，反之 hit_o=0。tag_o (data_o) 的設定方式是如果 hit_0=1或 hit_1=1 就設成對應的 tag (data)，如果 miss 了就要選比較久以前的那個把它覆蓋掉，覆蓋掉之後就會變比較新的

### Pipeline_Registers.v

加上從 `dcache_controller.v` 傳送出來的 cache stall 訊號，即當 cache miss 的時候要等待 Data Memory 執行的時間，如果 stall 訊號是 1，則所有 pipeline registers 都保留原本的值不更新，即可達到整個 CPU wait 的效果

### CPU.v
CPU module 讀入 clock 訊號、reset bit 和 start bit，在每個 clock 根據 PC 值循序從 instruction memory 讀取指令，並根據不同 operation 在各 module 有不同的 input 和 output values，最終把運算結果存入指定的 Register File 或是 Data Memory。為了在有 Pipeline Registers 的情況下串起整個 data path， 需要所有電路分別宣告成 wire，再將這些 wires 連接到對應 module 和 Pipeline Registers 的 ports，配合我們設計的 Pipeline Registers 只在 clock positive edge 更新的機制，可讓 Pipeline CPU 正常運作

