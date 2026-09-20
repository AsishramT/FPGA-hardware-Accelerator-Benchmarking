# FPGA Hardware Accelerator Benchmarking

## Overview

This project compares matrix multiplication performance across:

- Python
- Optimized C++
- A custom SystemVerilog FPGA-style hardware accelerator

The hardware design was developed progressively from a basic multiplier into a parameterized, parallel matrix multiplication accelerator.

The project focuses on two main questions:

1. How do Python and optimized C++ compare for matrix multiplication?
2. How does increasing FPGA-style hardware parallelism affect execution cycles and synthesized hardware resources?

---

## Project Structure

```text
FPGA Hardware Accelerator Benchmarking/
│
├── Benchmark/
│   ├── Cpp/
│   │   ├── MatrixMultiplier.cpp
│   │   ├── matrix
│   │   └── Cpp_results.txt
│   │
│   └── Python/
│       ├── MatrixMultiplier.py
│       └── py_results.txt
│
├── FPGA_Hardware/
│   ├── RTL/
│   │   ├── Multiplier.sv
│   │   ├── MAC.sv
│   │   ├── DotProduct.sv
│   │   ├── MatrixMultiplier.sv
│   │   ├── ParallelMatrixMultiplier.sv
│   │   └── ParallelMatrixMultiplierSynth.sv
│   │
│   ├── Testbench/
│   │   ├── Multiplier_tb.sv
│   │   ├── MAC_tb.sv
│   │   ├── DotProduct_tb.sv
│   │   ├── MatrixMultiplier_tb.sv
│   │   └── ParallelMatrixMultiplier_tb.sv
│   │
│   └── Simulation/
│       └── simulation outputs and synthesis results
│
├── .gitignore
└── README.md
```

---

## Software Implementations

Python and C++ implementations use the standard three-loop matrix multiplication algorithm:

```cpp
for (int row = 0; row < N; row++) {
    for (int col = 0; col < N; col++) {
        for (int k = 0; k < N; k++) {
            C[row][col] += A[row][k] * B[k][col];
        }
    }
}
```

For each matrix size:

- Input matrices are generated before timing begins.
- The same matrices are reused across five runs.
- The five execution times are averaged.
- Matrix generation time is excluded from the benchmark.

The C++ implementation was compiled using:

```bash
g++ -std=c++17 -O2 MatrixMultiplier.cpp -o matrix
```

---

## Software Benchmark Results

| Matrix Size | Python Average (ms) | C++ Average (ms) | Python / C++ Ratio |
|------------:|--------------------:|-----------------:|--------------------:|
| 16×16 | 0.119183 | 0.001754 | ~68.0× |
| 32×32 | 0.938395 | 0.016831 | ~55.8× |
| 64×64 | 7.671057 | 0.092188 | ~83.2× |
| 128×128 | 60.822099 | 0.652322 | ~93.2× |
| 256×256 | 492.552312 | 4.710050 | ~104.6× |

At `256×256`:

```text
Python ≈ 492.55 ms
C++    ≈   4.71 ms
```

The optimized C++ implementation completed the test approximately `104.6×` faster than the pure Python implementation.

Raw timing data is stored in:

```text
Benchmark/Cpp/Cpp_results.txt
Benchmark/Python/py_results.txt
```

---

## RTL Development

The accelerator was developed incrementally:

```text
Multiplier
    ↓
Multiply-Accumulate Unit
    ↓
Dot Product Engine
    ↓
2×2 Matrix Multiplier
    ↓
Parameterized N×N Matrix Multiplier
    ↓
Parallel Matrix Accelerator
```

This progression was used to build and verify each part of the datapath before increasing the complexity of the design.

---

## Accelerator Architecture

The accelerator contains:

- An FSM-based controller
- Row, column, and inner-product index registers
- Multiply-accumulate datapath
- Parameterized matrix size
- Configurable parallel multiplier lanes
- Result storage
- Cycle counter
- `start` / `done` control signals

The controller uses three states:

```text
IDLE → CALCULATE → FINISHED
```

The hardware registers:

```text
row
col
k
```

perform the role of the software loop indices.

---

## Parallel Datapath

Parallelism is controlled using:

```systemverilog
parameter int LANES = 4;
```

With one lane, one multiplication is processed during each computation step:

```text
Clock 1 → A0 × B0
Clock 2 → A1 × B1
Clock 3 → A2 × B2
Clock 4 → A3 × B3
```

With four lanes, four products can be generated in parallel:

```text
A0 × B0 ──┐
A1 × B1 ──┤
A2 × B2 ──┼──→ parallel_sum → accumulator
A3 × B3 ──┘
```

The theoretical computation cycle count is:

```text
cycles = N² × ceil(N / LANES)
```

---

## Functional Verification

The SystemVerilog testbench independently calculates a reference result and compares every output element against the RTL result.

The testbench:

1. Generates matrices A and B.
2. Calculates the expected matrix result.
3. Sends the `start` signal.
4. Waits for `done`.
5. Compares every matrix element.
6. Reports `PASS` or `FAIL`.

Example:

```text
Matrix size = 16x16
Parallel lanes = 4
Accelerator cycles = 1024
PASS
```

The parameterized RTL was also simulated with larger matrix sizes to verify indexing and control behavior.

---

## Synthesis

Generic synthesis was performed using Yosys 0.33.

The simulation-oriented RTL uses multidimensional SystemVerilog matrix ports. Because the installed Yosys frontend does not support those ports directly, a synthesis-specific version uses flattened matrix buses.

Example:

```text
Simulation:

A[row][col]

Synthesis:

A_flat[bit_position +: 8]
```

The accelerator datapath and control architecture remain equivalent.

---

## 16×16 Parallel Synthesis Results

The synthesis experiment keeps the matrix size fixed at:

```text
N = 16
```

and varies the number of parallel multiplier lanes.

| LANES | Cycles | Multipliers (`$mul`) | Adders (`$add`) | Muxes (`$mux`) | Total Cells |
|------:|-------:|---------------------:|----------------:|---------------:|------------:|
| 4 | 1024 | 4 | 21 | 19 | 96 |
| 8 | 512 | 8 | 37 | 23 | 132 |
| 12 | 512 | 12 | 53 | 27 | 168 |
| 16 | 256 | 16 | 69 | 31 | 204 |

The synthesized multiplier count scales directly with the configured parallelism:

```text
LANES = 4  →  4 multipliers
LANES = 8  →  8 multipliers
LANES = 12 → 12 multipliers
LANES = 16 → 16 multipliers
```

This confirms that increasing `LANES` results in additional multiplier hardware during synthesis.

---

## Area vs. Performance

The synthesis results show the main hardware tradeoff:

```text
More parallel lanes
        ↓
More arithmetic hardware
        ↓
Higher resource usage
        ↓
Fewer execution cycles
```

For example:

```text
4 lanes
96 cells
1024 cycles

        ↓

16 lanes
204 cells
256 cycles
```

Increasing from 4 to 16 lanes reduces the computation cycle count by `4×`, while generic synthesized cell usage increases from `96` to `204`.

The `8`-lane and `12`-lane results also demonstrate that additional hardware does not always improve latency:

```text
8 lanes  → 512 cycles
12 lanes → 512 cycles
```

For a 16-element dot product:

```text
ceil(16 / 8)  = 2
ceil(16 / 12) = 2
```

Both architectures therefore require two computation chunks per output element.

The 12-lane design uses four additional multipliers without reducing the total cycle count for this workload.

This illustrates an important accelerator-design principle: parallel hardware must be matched efficiently to the workload.

> Yosys `$mul`, `$add`, `$mux`, and total-cell counts are generic synthesis operators. They are not equivalent to final FPGA DSP, LUT, or flip-flop utilization.

---

## Key Results

### CPU

```text
256×256 Python: 492.55 ms
256×256 C++:      4.71 ms
```

### RTL

```text
16×16, 4 lanes:   1024 cycles
16×16, 8 lanes:    512 cycles
16×16, 12 lanes:   512 cycles
16×16, 16 lanes:   256 cycles
```

### Synthesis

```text
4 lanes  →  4 multipliers,  96 cells
8 lanes  →  8 multipliers, 132 cells
12 lanes → 12 multipliers, 168 cells
16 lanes → 16 multipliers, 204 cells
```

---

## Tools

- SystemVerilog
- Verilog
- Icarus Verilog
- Yosys
- C++
- Python
- GTKWave
- Git
- VS Code
- WSL Ubuntu

---

## Skills Demonstrated

- RTL design
- FPGA accelerator architecture
- Finite state machines
- Multiply-accumulate datapaths
- Parameterized SystemVerilog
- Hardware parallelism
- Self-checking testbenches
- Cycle-based performance analysis
- Logic synthesis
- CPU benchmarking
- Hardware/software performance comparison
- Area-performance tradeoff analysis

---

## Future Improvements

Potential future extensions include:

- Pipelined reduction trees
- Block RAM-based matrix storage
- FPGA-specific synthesis and place-and-route
- DSP block mapping
- Maximum clock-frequency analysis
- Matrix tiling
- Streaming interfaces
- AXI integration
- Systolic-array architecture
- Physical FPGA deployment