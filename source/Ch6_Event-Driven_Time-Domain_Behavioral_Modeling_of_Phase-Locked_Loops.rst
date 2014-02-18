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

.. figure:: ./img/ch4_fig2.png
  :alt: Figure2: Block Diagram of a PLL

* 2つの信号の位相差が0であれば、周波数も同じになる。すなわち、位相がロックされると、通常、周波数もロックされる。この位相と周波数のロック現象により、基本のループ回路から、たくさんのPLLと回路を作ることができる。オペアンプのように、PLLもICの中でクリティカルなところに使用される。デジタルチップでは、クロック生成やクロックデスキュー用に使用される。また、通信用チップでは、PLLは周波数シンセサイザ[1]やクロックデータリカバリ回路[2]に用いられる。他には、AD変換器の中で使用されたり、信号の復調や、フィルタリング、モータの速度制御に使用される[3]。

.. If the phase difference at the inputs is zero, the frequencies of the two input signals will be the same. Phase lock usually implies frequency lock also. Both phase and frequency locking provide many uses for PLLs and circuits derived from the basic loop. Much like op-amps, PLL circuits can be used in many critical applications in integrated circuits. In digital chips, PLLs are used in clock generation and clock de-skewing applications. In communications chips, PLLs are used for precision frequency generation and synthesis[1] and in clock recovery applications[2]. Other uses include A/D conversion, demodulation of signals, filtering, and motor speed control[3]

* 図2に示すとおり、PLLの基本要素は、位相検出器(もしくは、位相・周波数検知器(PFD))、チャージポンプ回路、ループフィルタと電流/電圧制御発振器からなる。位相検出器は、2つの入力信号の位相差を検出し、位相差に応じた電流/電圧を生成する。チャージポンプ回路は、位相検出器の出力から、ループフィルタをドライブするための電流に変換する。ループフィルタは、誤差信号を平均化し、発振器の制御信号に変換する。原則として、PLLのは周期的な入力信号、もしくは、少なくともある期間だけは周期的な信号となっていることを仮定している。

.. The basic components of a PLL, as shown in Figure 2, are a phase detector or Phase-Frequency Detector (PFD), a charge-pump, a loop filter, and a current or voltage controlled oscillator. The phase detector is used to detect the difference in phase between the input signals, creating some type of error current or voltage. The charge-pump converts the phase detector output into a signal for driving the loop filter. The loop filter averages the error signal to provide a smooth control signal for the oscillator. A PLL typically assumes a periodic input, or at least an input that is periodic for a given amount of time.

* 2000年までは、PLLのモデリングは、ある種、芸術的なものであった。近年は、CPUの速度が上がったこともあり、PLL全体の回路でも回路シミュレータで数時間で解けるようになってきた。しかしながら、たとえジッタや位相雑音を考慮しなくともロック状態を過渡解析でシミュレーションするのは、未だに問題がある。そのため、正確なビヘイビアモデルによりシステムシミュレータで解析する必要がある。このシミュレーションには、時間領域・周波数領域で、ジッタや位相雑音などの不完全性を考慮する必要がある。正確なPLLのシミュレーションのために、イベント・ドリブン型のモデルを使用する場合のトレードオフについて、説明する。イベント・ドリブンのモデルは、周波数領域のモデルに置き換わるものである。回路設計の結果や過渡解析の結果から、非理想的なPLLのモデルを作成する方法についても説明する。非理想的な現象を再現するために、ビヘイビアモデルにノイズ源を配置しなければならない。イベント・ドリブンモデルを使用した場合の時間領域におけるジッタのモデリングの問題についても議論する。また、p.215の"PLL Model and Comparison"で、位相のモデルとの比較を行う。

.. Prior to 2000, the modeling of PLLs was something of an art form. In recent years, with advances in processor speeds, it has become possible to simulate a full PLL design, in a few hours, with circuit simulators. It still can be a problem to simulate the lock transient of a PLL design even without simulating effects such as jitter or phase noise. Accurate behavioral modeing approaches are needed to provide designers with models that can be inserted into system simulations. The effects of circuit imperfections, jitter, and phase noise need to be studied in these applications in both the time and frequency domains. An overview of the trade-offs in using event-driven models for obtaining accurate simulation of PLLs is provided. Event-driven models are an alternative to phase-domain models. An overview of modeling basic non-idealmes in PLL circuits from a circuit design and time-domain view is given. Emphasis is placed on finding the relevant circuit nori-idealitIes and adding them to behavioral models. The issues associated with time-domain jitter modeling using the event-driven model are discussed. A comparison to phase domain modals is given in the section "PLL MOdel and Comparison", on page 215.


Analysis of PLLs
====================

* PLLの計算方法について、簡単に説明する。まず、最初の節では、位相ドメインでの解析方法について述べる。2番めのセクションでは、改良した位相ドメインのモデルについて述べる。位相ドメインのモデルは、周波数解析にしか使用できないため、3つ目のセクションで時間領域で解く方法について述べる。

.. A brief synopsis of methods for analyzing PLLs is presented. The first section will illustrate the phase-domain analysis. The second section introduces an improvement to the phase-domain model. The phase-domain model is analyzed with respect to frequency, so the third section will describe PLL analysis with respect to time.


A Continuous-Time Phase-Domain Approximation for Frequency Domain Analysis
------------------------------------------------------------------------------------

Discrete-Time Phase-Domain Models for Frequency-Domain Analysis
------------------------------------------------------------------------------------

Time-Domain Simulation
------------------------------------------------------------------------------------


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

