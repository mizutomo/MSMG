==============================
Ch.3 AMS Behavioral Modeling
==============================

Overview
====================================

* Analog設計者は、これまでボトムアップ手法により設計を行なってきた。
* 複数のサブシステムを含んだシミュレーションを行うとき、Trレベルでは時間がかかるため、一部ブロック(特性として見る必要のないブロック)をビヘイビアモデルに置き換えるなど、シミュレーションの高速化のためだけに機能モデルを使用してきた。


* このようなボトムアップアプローチは、対処療法的であり、プロジェクトの銀の弾丸ではない。


* システム設計段階から、モデルによりスペックの検証を行うトップダウン設計に移行する必要がある。


* トップダウン・アプローチを取ることで、Executable Spec(検証可能な仕様書)となる。


Modeling classifications
====================================

* アナログの場合、決まった抽象度というものがない。また、デジタルと異なり、モデル開発をサポートするようなツールもほとんどないため、モデル作成にかかる時間が千差万別となる。
* シミュレーション時間も、抽象度によって、大きく異る。
* 効率的なシミュレーションを行うためには、要求に応じた適切な抽象度・複雑度のモデルを用意する必要がある。


* モデリングする際には、以下のことを考慮する必要がある。

  * 対象としているシミュレータがAnalog/Digital/Mixed-Signalを扱えるかどうか。
  * 適切な階層(抽象)構造となっているか。
  * モデルにどこまでの特性を組み込むか。1次の線形特性か、非線形特性か。


* モデル化において重要なことは、モデルの使用目的を把握すること。
* モデルの使用目的が把握できていないと、無駄に抽象度の低いモデルを作ったりしてしまう。


Model Development
-----------------------------------

* モデルの複雑さは、どのレベルであっても要素の数に依存する。

  * もし、ブロックが巨大なピン数を持っていた場合、リーズナブルなレベルまでブレークダウンさせる。
  * ただし、これ以上機能として分割できないようなレベルにまで落とし込むのは、機能モデルとしては適切ではない。


Design Topological Considerations
-----------------------------------

* サブシステムへの分割の仕方は非常に重要である。

* 時には、常識が誤った方向に導くことがある。
* 通常、デジタル回路によって制御されるアナログ回路があった場合、2つのブロックに分けられがちである。
* 上記のように分けてしまうと、アナデジ間の制御信号の抽象度が非常に低くなるだけでなく、2つのモジュールがセットでないと、検証ができなくなる。
* モジュールを一つにして、ブロック(always?)で分割するのがよい。


Types of Modeling
====================================

* 一般的に、大規模システムの検証に用いられる抽象度のレベルとしては、下記のものがあり、用途・目的に応じて、適切な使い分けが必要。

  * Device based design(Spectre, SPICE): 回路図から生成されたネットリスト、もしくは、Pure SPICEで解釈可能なマクロモデルで記述されたネットリスト。

  * Analog modeling(Verilog-A): 電流/電圧の関係式を記述したモデル。アナログソルバ(SPICE)で解かれる。

  * Mixed-signal modeling(Verilog-AMS, VHDL-AMS): アナログ動作とデジタル動作が同時に記述可能なレベル。

  * Discrete real number modeling(Verilog-AMS, VHDL, SystemVerilog): 電気的な動作を実数の信号レベルに置き換えたモデル。インピーダンス効果(電流・電圧の関係式)は無視され、デジタルソルバで解かれる。

  * Logic modeling(Verilog, VHDL, SystemVerilog): 0,1,X,Zでモデリング。


Discrete Digital Modeling
-----------------------------------

* デジタルの入出力関係だけが記述されたモデル。デジタルソルバで解析。アナログ要素は含まない。

* Verilog, VHDL, SystemVerilogで記述が可能。

* アナログIPでもデジタルの入出力のみに着眼して、本レベルで記述されることがある。


Continuous Analog Modeling
-----------------------------------

* システムの電気的特性が記述。言語は、Verilog-A。

* 電圧/電流の関係が記述。また、積分・微分オペレータも使用可能。

* Verilog-Aモデルは、非線形常微分方程式に変換。他のSPICEコンポーネントと同様の方法でSPICEソルバにより解析。

* Trレベルと比較して、10～50倍の高速化が可能。シミュレーションのスピードアップのためには、ノード数の削減と方程式数の削減が鍵。また、弱い非線型モデルにすることで、タイムステップを伸ばすことが可能。

* デジタルの記述は全て電気的特性に変換され、SPICEソルバで実行される。そのため、論理シミュレータで解くよりも低速になる。また、IPCを用いたCo-Simで解析することも可能であるが、解析速度はアナログシミュレータのタイプステップに律速される。


Mixed-Signal Modeling
-----------------------------------

* Mixed-Signalに対応したシミュレータは、1つのカーネルで離散的なデジタル回路と連続的なアナログ回路を解くことができる。

* Verilog-AMS, VHDL-AMSが記述に用いられる。

* AMSでは、デジタルとアナログを自然にそれぞれの抽象度で記述することができる。また、データとイベントは相互に通信可能。


Real Number Modeling
-----------------------------------

* 電気的な信号を実数としてモデル化する手法。実数信号は、電圧もしくは電流のどちらかを表現するのに使用される。

* RNMは、Verilog-AMS, SystemVerilog, VHDLで使用可能。

* RNMは、デジタルソルバのみで解かれるため、SPICEと比べて1000～100万倍の高速化が可能。

* 双方向的なアナログの相関関係をモデリングすることはできない。


Combined Approaches
-----------------------------------

* 実際には、上記の抽象度のレベルを混ぜて使用されることが多い。

* 例えば、RFレシーバの場合、下記の抽象度が混在で使用される。

    * RF信号パス: RNM
    * ベースバンド, バイアス、パワー供給: Electrical
    * 制御回路: ロジック


Basic Moeling Formats
====================================

| この本の目的は、4タイプの記述方法における長所・短所に対する洞察力をつけること。
| 各記述方法における例(Programable-Gain Amplifier)を例に述べていく。


Model Operational Description
------------------------------------------------

* 差動入力、差動出力。出力には入力をゲイン倍した電圧が出力される。
* ゲインは、デジタルの3bitバス入力(GAIN[2:0])。
* 実際のPGAにあるその他のピン(電源、バイアス入力、出力のEnable信号)あり。
* 出力は、(VDD-VSS)/2を中心とする。
* 出力端子の出力抵抗はRoutとする。

 .. csv-table:: List of terminals
    :header: "pinName","expression" 
    :widths: 20,70

    "INP,INM","差動入力 V(INP,INM)" 
    "OUTP,OUTN","差動出力 V(OUTP,OUTN)"
    "GAIN[2:0]","ゲイン制御端子( dbmin@GAIN=000, dbmax@GAIN=111 )" 
    "VDD,VSS","電源"
    "VB","バイアス入力"
    "EN","Enable信号( ハイインピーダンス@EN=0, 通常出力@EN=1 )"


AMS Programmable-Gain Amplifier Model
---------------------------------------------------

* `pga_verilogams <../txt/pga_verilogams.txt>`_

::

  `include "disciplines.vams"  
  modele PGA (OUTP,OUTN, INP,INN, GAIN, VB, VDD,VSS, EN);  
  output OUTP,OUTN;		// differential output 
  input  INP,INN;    		// differential input
  input [2:0] GAIN;   		// digital control bus
  input VDD,VSS,VB;    		// power supplies & bias voltage input
  input EN; 			// output enable
  electrical OUTP,OUTN, INP,INN, VB, VDD,VSS; 
  logic EN;  logic [2:0] GAIN; 
 
  parameter real dbmin=-1;	// gain for VCVGA=000
  parameter real dbmax=20;	// gain for VCVGA=111
  parameter real Rout=100;	// output resistance for each pin
  parameter real Tr=10n;	// rise/fall time for gain & enable changes
  real DBinc, Adb, Av;		// terms in gain calculation
  real Voctr,Vomax,Vodif;	// terms in output calculation
  real Gout;			// output conductance (smoothly switched)
  integer Active;		// flag for active operation
 
  initial DBinc=(dbmax-dbmin)/7;	// compute per-bit change to db gain
  always begin
    if( (^GAIN)===1'bx ) Adb=-40;	// low gain if invalid control input
    else Adb=dbmin+DBinc*GAIN;		// compute gain in dB
    @(GAIN);				// recompute on gain bus change
  end
 
  analog begin
  // Check device is active (EN high, supply & bias correct):
    Active = (EN===1'b1) && V(VDD,VSS)>=2.0 && abs(V(VB,VSS)-0.7)<=0.05;
    Av = transition(Active? pow(10,Adb/20.0):1u, 0, Tr);  		// convert to V/V
    Voctr = transition(Active,0,Tr)*V(VDD,VSS)/2;			// CM output level wrt Vss
    Vomax = max(V(VDD,VSS),0.001);					// max swing of output
    Vodif = Vomax*tanh(Av*V(INP,INN)/Vomax);				// gain & saturation limiting
 
  // Driver output pins with differential Gain*input at Rout if active,
  // high impedance if disabled, or high attenuation on bias error:
    Gout = transition( (EN===1'b1)? 1/Rout:1n, 0,Tr);
 
    I(OUTP,VSS) <+ (V(OUTP,VSS) - (Voctr+Vodif/2)) * Gout;
    I(OUTN,VSS) <+ (V(OUTN,VSS) - (Voctr+Vodif/2)) * Gout;
 
  end
  endmodule



端子の属性定義
^^^^^^^^^^^^^^^^^^^^^^^^^^^

    * deciplines.vamsを定義(/common/appl/Cadence/mmsim/12.1_isr2/linux/tools.lnx86/spectre/etc/ahdl/deciplines.vams)
    * アナログ信号(入出力、電源、バイアス入力)は、electricalで定義。analogブロック内で使われI(),V()を使用して測定。アナログソルバで解かれる。
    * デジタル信号(GAIN,EN)は、logicで定義。デジタルブロック内で使われ、1,0,X,Zの値を持つ。デジタルソルバで解かれる。

パラメータ定義
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    * 定義した数値はデフォルトで、後から変更可能。
    * Trは、スペックではない。ただし、ゲインとコンダクタを変える場合にランプ的に変更するのに使用する。設定しないと、アナログソルバでtime step errorが発生します。

内部変数定義
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    * realとintegerは内部変数。
    * アナログブロックでもデジタルブロックでもどちらでも使用できるが、どちらか一方でしかアクセス出来ない。
    * アナログの場合はanalogブロック内でアップデートされ、デジタルの場合はinitialかalwaysブロック内でアップデートされる。

デジタルブロック
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    1. initial文: Simulationの最初で計算される。

      * DBinc(GAINの1bit辺りのゲイン増加両)を計算。

    2. always文: Sim中繰り返し計算される。

      * GAINの各Bitをexclusive-ORする事で、入力信号にXが含まれるかを確認する。
      * GAIN[2:0]にXが含まれる場合はAdb=-40を設定、含まれない場合は、Adb= dbmin+DBinc*GAINでゲインを計算。
      * @(GAIN)が重要。これを入れることによって、always文の解析が次のGAIN信号が変化した時に評価されるようになる。これが無かったら、解析時間は0[sec]で止まってしまい永久ループとなってしまう。



アナログブロック
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    * | Activeフラグは、EN信号と電源電圧、バイアス電圧で決定。
      | 電源電圧≧2.0[V]、バイアス電圧=0.7±0.05V[V]。
    * | Avは、Adb(ゲイン)をdBから比率に変更したもの。
      | Active=1の時に計算結果、Active=0の時は0.001とする。
      | Adbの急激な変化によるtime step errorを防ぐためにtransition関数で立ち上がりにTrの時間を設けている。
    * | Voctrは、コモン電圧で電源電圧の1/2。ただし、電源・バイアスを満たさない場合には供給されないため、Active信号で制御。
      | Active信号は急峻に変化するため、transition関数で立ち上がりにTrの時間を設けている。
    * | Vomaxは、出力のpeak-to-peakの最大出力のため電源電圧で定義。ただし、電源電圧が供給されていない場合には、0.001[V]とする。
    * | Vodifは、差動出力の信号成分。
      | 入力差動信号をゲイン倍したものになるが、AMPの動作電圧で飽和する。
      | min/maxで簡単に定義する事も出来るが、実回路特性に近づけるためtanh(ハイパーボリックタンジェント)関数を使用して緩やかにリミットがかかるようにした。 
 
    .. image::  ./img/vodif.png
       :alt: Inputとoutputの関係

    * | Goutは、出力コンダクタンス。
      | EN=1の場合は1/Routだが、EN=0の場合は1/1GΩとなる。ENの2値の切換えにはtransition関数を使用する。
      | (100Ωから0.1%の変化で1MΩに到達するためEN信号による切換えは直ぐに行われる。)
    * | 出力端子の電流/電圧の関係を示す。コントリビューション文(<+)を使用する事で、分岐点における電流と電圧の関係をノード解析によって求める。
      | 出力電圧だけであれば、V(OUTP,VSS)<+Voctr+Vodif/2;で示せるが、コンダクタンスを式に加える事で電流成分も表す。


Analog PGA Model
-----------------------------------------

  * `pga_veriloga <../txt/pga_veriloga.txt>`_

::

  `include "disciplines.vams"
  module PGA ( OUTP,OUTN, INP,INN, GAIN, VB, VDD,VSS, EN );
  output OUTP,OUTN;             // differential output
  input  INP,INN;               // differential input
  input [2:0] GAIN;             // digital control bus
  input VDD,VSS,VB;             // power supplies & bias voltage input
  input EN;                     // output enable
  electrical OUTP,OUTN, INP,INN, VB, VDD,VSS, EN;
  electrical [2:0] GAIN;

  parameter real dbmin=-1;      // gain for VCVGA=000
  parameter real dbmax=20;      // gain for VCVGA=111
  parameter real Rout=100;      // output resistance for each pin
  parameter real Tr=10n;        // rise/fall time for gain & enable changes
  real DBinc, Adb, Av;          // terms in gain calculation
  real Voctr,Vomax,Vodif;       // terms in output calculation
  real Gout;                    // output conductance (smoothly switched)
  integer Active;               // flag for active operation

  // Macro to convert pin coltage to logic level of 1 or 0 based on half supply:
  `define L(pin) (V(pin,VSS)>V(VDD,VSS)/2)
  
  analog begin
  // Check when enabled & biased properly:
    Avtive = `L(EN)==1 && V(VDD,VSS)>=2.0 && abs(V(VB,VSS)-0.7)<=0.05;

  // Gain calculation:
    @(initial_step) DBinc = (dbmax-dbmin)/7;		// compute per-bit increment
    Gint = `L(GAIN[2])*4 + `L(GAIN[1])*2 + `L(GAIN[0]);	// get integer form of GAIN
    Adb = dbmin + DBinc*Gint;				// convert to gain in dB
    Av = transition( Active? pow(10,Adb/20.0):1u, 0,Tr);	// to V/V or small if off

  // Output signal evaluation:
    Voctr = transition(Active,0,Tr)*V(VDD,VSS)/2;                       // CM output level wrt Vss
    Vomax = max(V(VDD,VSS),0.001);                                      // max swing of output
    Vodif = Vomax*tanh(Av*V(INP,INN)/Vomax);                            // gain & saturation limiting

  // Driver output pins with differential Gain*input at Rout if active,
  // high impedance if disabled, or high attenuation on bias error:
    Gout = transition( `L(EN)? 1/Rout:1n, 0,Tr);

    I(OUTP,VSS) <+ (V(OUTP,VSS) - (Voctr+Vodif/2)) * Gout;
    I(OUTN,VSS) <+ (V(OUTN,VSS) - (Voctr+Vodif/2)) * Gout;

  end
  endmodule


* アナログモデルは、デジタルソルバが無い場合、又は全PINがアナログ端子として定義されている場合に使用され、VerilogAで記述される。
* 

