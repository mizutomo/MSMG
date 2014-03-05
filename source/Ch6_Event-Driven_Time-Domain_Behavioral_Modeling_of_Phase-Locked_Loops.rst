==========================================================================================
Ch.6 Event-Driven Time-Domain Behavioral Modeling of Phase-Locked Loops
==========================================================================================

Introduction
=================

* この節では、PLLのビヘイビアモデルについて説明する。まず最初に、PLLの回路設計の課題が、ビヘイビアモデルとどのように関係しているかを示す。もし、回路設計の経験があるのであれば、より精度のよいモデルを作るのに役立つだろう。その後、イベント・ドリブン型のPLLのモデルについて説明する。イベントドリブンのモデルにすることで、非常に高速に実行することができる。最後に、複雑なアルゴリズムを実装するために、プログラミング言語としてVerilog-AMSを使う方法について説明する。

.. This chapter discusses Phase-Locked Loop (PLL) behavioral modeling. First it shows how to link PLL circuit design issues with behavioral modeling techniques. Having circuit design experience helps to write more accurate models. Then, event-driven modeling of PLLs is discussed. Event-driven modeling can provide very fast models. Finally it shows how to use Verilog-AMS as a programming language to implement complex algorithms.

* PLLは、入力信号とVCOから出力される信号との位相差をなくすための回路である。これは、オペアンプを使用した負帰還の回路に似ている。オペアンプの負帰還回路では、2つの端子の電圧が同じになるように働く。

.. A PLL is a circuit that attempts to eliminate the phase difference between an input signal and a signal generated from a controlled oscillator. This is analogous to an op-amp placed in a negative feedback loop. The op-amp circuitis analyzed by assuming the two terminals are at equal voltages.

.. figure:: ./img/ch6_fig1.png
  :alt: Figure1: Example of Voltage Analysis in the Frequency Domain

* 図1にオペアンプを使用したボルテージフォロア回路と反転増幅回路の例を示す。両方の回路共に、電圧を変数として、周波数ドメインで、特性を記述することができる。ボルテージフォロア回路の伝達関数は、回路を見るだけで容易に導くことができる。それに対して、非反転増幅器は、オペアンプの2つの入力が等しいと仮定して、キルヒホッフの電流則を使用しないと導くことができない。PLLの場合は、位相の情報を用いて、位相ドメインの式を解析的に導くことができる。図2にPLLのフィードバックパスとフォワードパスを持った位相ドメインのモデルを示す。設定によっては、PLLはユニティゲインバッファのように振る舞う。

.. Figure 1 shows two examples of a voltage follower and an inverting gain stage. Both can be analyzed using voltage variables in the frequency domain. The transfer function for the voltage follower is easily derived by inspection. The non-inverting amplifier follows by applying Kirchhoff's current law after assuming the voltages at the two op-amp inputs are equal. PLLs are often analyzed using phase as the analysis variable, leading to a phase-domain model. Figure 2 illustrates a basic phase-domain model of a PLL, with the output feedback and the forward gain path shown. In this configuration, the PLL is like a unity gain buffer

.. figure:: ./img/ch6_fig2.png
  :alt: Figure2: Block Diagram of a PLL

* 2つの信号の位相差が0であれば、周波数も同じになる。すなわち、位相がロックされると、通常、周波数もロックされる。この位相と周波数のロック現象により、基本のループ回路から、たくさんのPLLと回路を作ることができる。オペアンプのように、PLLもICの中でクリティカルなところに使用される。デジタルチップでは、クロック生成やクロックデスキュー用に使用される。また、通信用チップでは、PLLは周波数シンセサイザ[1]やクロックデータリカバリ回路[2]に用いられる。他には、AD変換器の中で使用されたり、信号の復調や、フィルタリング、モータの速度制御に使用される[3]。

.. If the phase difference at the inputs is zero, the frequencies of the two input signals will be the same. Phase lock usually implies frequency lock also. Both phase and frequency locking provide many uses for PLLs and circuits derived from the basic loop. Much like op-amps, PLL circuits can be used in many critical applications in integrated circuits. In digital chips, PLLs are used in clock generation and clock de-skewing applications. In communications chips, PLLs are used for precision frequency generation and synthesis[1] and in clock recovery applications[2]. Other uses include A/D conversion, demodulation of signals, filtering, and motor speed control[3]

* 図2に示すとおり、PLLの基本要素は、位相検出器(もしくは、位相・周波数検知器(PFD))、チャージポンプ回路、ループフィルタと電流/電圧制御発振器からなる。位相検出器は、2つの入力信号の位相差を検出し、位相差に応じた電流/電圧を生成する。チャージポンプ回路は、位相検出器の出力から、ループフィルタをドライブするための電流に変換する。ループフィルタは、誤差信号を平均化し、発振器の制御信号に変換する。原則として、PLLのは周期的な入力信号、もしくは、少なくともある期間だけは周期的な信号となっていることを仮定している。

.. The basic components of a PLL, as shown in Figure 2, are a phase detector or Phase-Frequency Detector (PFD), a charge-pump, a loop filter, and a current or voltage controlled oscillator. The phase detector is used to detect the difference in phase between the input signals, creating some type of error current or voltage. The charge-pump converts the phase detector output into a signal for driving the loop filter. The loop filter averages the error signal to provide a smooth control signal for the oscillator. A PLL typically assumes a periodic input, or at least an input that is periodic for a given amount of time.

* 2000年までは、PLLのモデリングは、ある種、芸術的なものであった。近年は、CPUの速度が上がったこともあり、PLL全体の回路でも回路シミュレータで数時間で解けるようになってきた。しかしながら、たとえジッタや位相雑音を考慮しなくともロック状態を過渡解析でシミュレーションするのは、未だに問題がある。そのため、正確なビヘイビアモデルによりシステムシミュレータで解析する必要がある。このシミュレーションには、時間領域・周波数領域で、ジッタや位相雑音などの不完全性を考慮する必要がある。正確なPLLのシミュレーションのために、イベント・ドリブン型のモデルを使用する場合のトレードオフについて、説明する。イベント・ドリブンのモデルは、周波数領域のモデルに置き換わるものである。回路設計の結果や過渡解析の結果から、非理想的なPLLのモデルを作成する方法についても説明する。非理想的な現象を再現するために、ビヘイビアモデルにノイズ源を配置しなければならない。イベント・ドリブンモデルを使用した場合の時間領域におけるジッタのモデリングの問題についても議論する。また、p.215の"PLL Model and Comparison"で、位相のモデルとの比較を行う。

.. Prior to 2000, the modeling of PLLs was something of an art form. In recent years, with advances in processor speeds, it has become possible to simulate a full PLL design, in a few hours, with circuit simulators. It still can be a problem to simulate the lock transient of a PLL design even without simulating effects such as jitter or phase noise. Accurate behavioral modeing approaches are needed to provide designers with models that can be inserted into system simulations. The effects of circuit imperfections, jitter, and phase noise need to be studied in these applications in both the time and frequency domains. An overview of the trade-offs in using event-driven models for obtaining accurate simulation of PLLs is provided. Event-driven models are an alternative to phase-domain models. An overview of modeling basic non-idealmes in PLL circuits from a circuit design and time-domain view is given. Emphasis is placed on finding the relevant circuit nori-idealitIes and adding them to behavioral models. The issues associated with time-domain jitter modeling using the event-driven model are discussed. A comparison to phase domain modals is given in the section "PLL MOdel and Comparison", on page 215.


Analysis of PLLs
====================

* PLLの計算方法について、簡単に説明する。まず、最初の節では、位相ドメインでの解析方法について述べる。2番目のセクションでは、改良した位相ドメインのモデルについて述べる。位相ドメインのモデルは、周波数解析にしか使用できないため、3つ目のセクションで時間領域で解く方法について述べる。

.. A brief synopsis of methods for analyzing PLLs is presented. The first section will illustrate the phase-domain analysis. The second section introduces an improvement to the phase-domain model. The phase-domain model is analyzed with respect to frequency, so the third section will describe PLL analysis with respect to time.


A Continuous-Time Phase-Domain Approximation for Frequency Domain Analysis
------------------------------------------------------------------------------------

* ここで説明する位相ドメインのアプローチは、Garner[4]が発表した手法に似ている。図2のPLLのモデルの個々のブロックについて、簡単に説明する。まず、解析のために、PLLがロックしている状態を仮定する。また、解析は周波数ドメインで行うため、ラプラス変数sを用いて、式を表現する。

.. The phase-domain approach presented here is similar to the one provided by Gardner[4]. The PLL shown in Figure 2 is analyzed. A brief discussion of each of the blocks in the figure is provided. A basic assumption for this analysis is that the PLL is locked. The analysis takes place in the frequency domain, so the Laplace variable s is used in the expressions.

* PFDブロックは、2つの入力信号の位相差を算出する。その後、(このモデルでは)チャージポンプ回路を用いて、位相差を電流に変換する。この変換ゲインを図2では、Kdetとしているが、ここでは簡単のため、1と仮定する。

.. The PFD computes the difference in phase between the two input signals. In this model, a chargepump is used to convert the phase difference to a current. There may be a gain associated with the Kdot as shown in Figure 2, but for this analysis, it is assumed to be 1.

* ループフィルタの伝達関数をH(s)とする。図3にチャージポンプPLLでよく使用されるループフィルタの回路とその伝達関数を示す。

.. The loop filter has a transfer function H(s). A common loop filler used in charge-pump PLLs is shown in Figure 3 along with an expression for H(s).

.. figure:: ./img/ch6_fig3.png
  :alt: Figure3: A Two Pole Loop Filter for a Charge-Pump PLL

* 電圧制御発振器(VCO)は、入力電圧から対応する周波数に変換する。入力電圧と周波数の関係は、下記の式で表現される。

.. The Voltage-Controlled Oscillator (VCO) converts the input voltage to an output frequency, and the relationship between input voltage and output frequency can be represented as:

.. figure:: ./img/ch6_exp1.png

* VcをVCOの制御電圧とし、電圧と周波数の関係が線形であると仮定すると、電圧と位相の関係式は、非常にシンプルなものとなる。

.. The quantity Vc is the control voltage for the oscillator. The mapping from voltage to frequency is assumed to be linear, so a first-order model is simply:

.. figure:: ./img/ch6_exp2.png

* 周波数ドメインでは、下記の式となる。

.. figure:: ./img/ch6_exp3.png

* 図2のVCOの箱の中には、ここで導いた伝達関数を書いている。

.. The transfer function for this equation was shown in Figure 2 within the VCO box.

* 位相ドメインでPLLの伝達関数を用いるために、まずはループをオープンにして、フォワード伝達関数を求める。ループを切るために、位相検出器の2番目の入力を0にする。一度に伝達関数を求めようとすると、巨大なものとなってしまうため、以下のように、いくつかの中間変数を定義する。

.. To derive a transfer function expressing the phase-domain model, the loop is first opened and analyzed to give the forward transfer function. To open the loop, assume that the second phase detector input is zero. The equations in the analysis become large, so several variables are defined in the following equations.

.. figure:: ./img/ch6_exp4.png

* これらの変数を使用することで、VCOの入力信号までの伝達関数は、以下のようになる。

.. Using these quantities, we can find the Laplace transform Vc(s) at the input of the VCO model.

.. figure:: ./img/ch6_exp5.png

* さらに、VCOのゲインを加え、位相の出力と入力の関係に式を直すことで、以下の開ループ特性が求まる。

.. Adding the VCO gain and moving to the output node gives the open loop transfer function:

.. figure:: ./img/ch6_exp6.png

* 開ループ特性は、ループの安定性を解析するのに役に立つ。この特性を用いることで、閉ループ特性は下記のように求まる。

.. The open-loop transfer function is useful for analyzing the stabihty of the loop. Solving this equation for the closed-loop transfer function gives:

.. figure:: ./img/ch6_exp7.png

* このケースでは、閉ループ特性は3次の特性を持っている。そのため、このタイプのPLLを3次のPLLと呼ぶ。閉ループ特性は、伝達特性においてピークを持つかどうかや、帯域を解析するのに役に立つ。これらの解析については、p.196の"Performance Metrics for PLLs"で述べる。

.. The closed-loop transfer function in this case is third-order, so the PLL is third order. The closed loop transfer function is useful for analyzing if there is peaking in the transfer function and for estimating the bandwidth of the PLL. The importance of these issues will be discussed in the Section "Performance Metrics for PLLs' on page 196.

* 位相に着目して伝達関数を求めるやり方の利点は、シンプルである、というものである。位相特性の定式化や周波数ドメインでの解析によって、短時間でのPLLの解析が可能となる。しかしながら、この手法は本質的に線形であることを仮定しているため、小信号解析にして適用できない。

.. The key advantage of the phase transfer function approach is the simplicity. The phase formulation and the frequency domain analysis open the door to rapid design exploration. However, the method inherently uses a linearized approximation, so it really only applies to small-signal analysis.


Discrete-Time Phase-Domain Models for Frequency-Domain Analysis
------------------------------------------------------------------------------------

* 先ほどの節では、位相検出器は完全な引き算器としてモデル化した。実際の回路では、位相の比較は、離散時間(通常は、クロックエッジ)で行われる。PLLがロックに近い状態にあるとき、位相の更新は、入力信号の速度で起こる。より本質的には、位相検出器は、固定のサンプリングレートで位相の更新を行う。前節で説明した解析は、位相検出の動作レートが、ループの帯域の10倍以上速い時に成り立つものである。この前提が成り立たない場合、誤差が大きくなる。連続時間での解析手法を用いる場合、位相検出器の周波数領域での動作が現れないため、このような現象を防ぐことができない。ループの位相と帯域を表現する式だけが、ガードを作ることができる。

.. In the last section, the assumption was made that the phase detector could be modeled by a pure subtractor. In actual circuits, the phase comparison happens at discrete periods of time, usually between the clock edges, When the PLL is near lock, the phase updates come at the rate given by the input source. In essence, the phase detector operates at a fixed sampling rate to produce updates. The analysis presented in the last section is approximate and works wellif the operating rate of the phase detector is more than ten times the bandwidth of the loop. If this is not the case, significant errors can be introduced. There is no guard for this when using continuous-time analysis as the frequency of operation for the phase detector does not appear in the analysis. Only expressions for phase of the loop and bandwidth of the loop are created.

* 離散時間領域での解析を行うことで、精度を向上させることができる。ロックに近い状態にあり、位相検出器の入力信号の周波数がサンプリングレートだとする。この場合、論文[5],[6]に離散時間でのモデルの作り方が研究されている。サンプリングされたデータを使うため、ループの周波数ドメインの情報を求めるために、Z変換と離散フーリエ変換が使用される。

.. To increase accuracy, a discrete-time analysis can be performed. The loop is assumed to be near lock, and the sampling rate is the frequency of input signals at the phase detector. Techniques for creating a discrete-lime model have been studied in the literature, allowing approximations to be developed [5] 161, Since sampled data is assumed, the z-transforin aird discrete-time Fourier transform are used to obtain frequency-domain information about the loop.


Time-Domain Simulation
------------------------------------------------------------------------------------

* これまで述べた2つのモデルは、両方共、周波数ドメインで解析を行ったものであった。周波数ドメインの解析の利点は、高速にシミュレーションが行えることである。逆に欠点としては、大信号・非線形の挙動がモデリングされていないことと、PLLのロック現象の時間変動現象をシミュレーションできないことである。時間領域のシミュレーションでも、周波数領域の解析で得ることができる情報と同じものを得ることができる。しかしながら、シミュレーション時間が非常に大きくなる。これは、周波数ドメインのシミュレーションは、固定の周波数刻みでしか解析しないのに対して、過渡解析では、非常にたくさんの時間ポイントで計算しないといけないためである。特に、波形の形状に関心があるときには、細かいタイムステップで解析する必要がある。時間領域のシミュレーションは、SPICEの過渡解析と関係が深いため、好んで使用される。

.. The previous two methods focused on frequency-domain analysis. The advantage of frequency domain methods is fast simulation time. The disadvantages are the lack of modeling for large signal non-linear behavior and the inability to studying time-varying phenomenon such as PLL locking transients. Time-domain simulation can be used to obtain the same information that the previous two methods provide. However, it comes at a significant cost in simulation time Frequency-domain simulation involves evaluation at a fixed number of frequency points, Time domain simulation requires the circuit to be evaluated at many time points, especially if the shape of the waveformis of interest. Time-domain simulation is often favored becauseitis more closely related to the circuit simulator transient analysis of SPICE simulation.

* 典型的には、タイムドメインのモデルは、アナログソルバによって、時間ステップ毎の電圧値が計算される。Verilog-Aのモデルは、アナログソルバによって解析される。対照的に、デジタルモデルはイベントドリブンであり、信号値が変化した時のみ、解が計算される。スイッチトキャパシタの回路では、イベントドリブンのモデルを使用することで、10倍以上の高速化が得られる[7]。PLLは、出力のエッジがイベントにより発生し、位相変化が発生したときのみループが更新されるため、イベントドリブンとしてモデル化できる。この章では、Verilog-AMSを用いてイベントドリブンのPLLモデルを開発する方法を示す。

.. Typical time-domain models make use of an analog solver that solves for voltage values on a timestep driven basis. Verilog-A models make use of the analog solver, In contrast, digital models typically are event-driven, requiring solutions only when signals change, For switched-capacitor circuits, speed-ups in the range of 10X or more can be achieved when using an event-driven model t71, A PLL can be modeled as an event-driven system since the output edges are events and the loop is only updated when the phase detector fires. This chapter shows how to create an event-driven PLL model in Verilog-AMS.


Performance Metrics for PLLs
==================================

Acquisition Range and Output Frequency Range
------------------------------------------------------------------------------------

PLL Stability
------------------------------------------------------------------------------------

Loop Bandwidth, Peaking, and Tracking Behavior
------------------------------------------------------------------------------------

Lock Time
------------------------------------------------------------------------------------

Static Phase Error
------------------------------------------------------------------------------------


Jitter
===========


Summary
------------

