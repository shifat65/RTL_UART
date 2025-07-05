# Baud Rate Generator (16× and 1×) — Verilog

The `baud_gen_16x` module generates two UART baud ticks:

* `baud_tick_16x` for oversampling-based UART RX
* `baud_tick_1x` for bit-accurate UART TX

It compares an externally provided counter (`count`) to a configurable divisor (`baud_div`) and outputs tick pulses at both 16× and 1× baud frequencies.

---

## Module Overview

### File: `baud_gen_16x.v`

```verilog
module baud_gen_16x(
    input  wire        clk,         // Input clock (e.g., 50 MHz)
    input  wire        rst_n,       // Active-low reset
    input  wire [15:0] count,       // External counter input
    input  wire [15:0] baud_div,    // Baud rate divisor

    output reg         baud_tick_1x,  // 1× baud tick (for TX)
    output reg         baud_tick_16x, // 16× baud tick (for RX)
    output reg         rst_c          // Counter reset signal
);
```

---

## Functional Description

* `clk`: Input system clock (should be fast enough to support oversampling).
* `rst_n`: Synchronous active-low reset.
* `count`: A free-running or resettable counter driven by `clk`.
* `baud_div`: Number of system clock cycles between each 16× tick.
* `baud_tick_16x`: A 1-cycle pulse at 16× baud rate, for oversampled RX.
* `baud_tick_1x`: A 1-cycle pulse every 16 `baud_tick_16x`, for TX.
* `rst_c`: Active-low signal to reset the external counter.

---

## Block Diagram

```
              +---------------------------+
 clk -------->|                           |
 rst_n ------>|       baud_gen_16x        |
 count ------>|                           |
 baud_div --->|                           |
              |                           |
              |  ┌─────────────────────┐  |
              |  │  if count == div-2  │  |
              |  └────────┬────────────┘  |
              |           │               |
              |           └─> baud_tick_16x ──┐
              |                               │
              |   ┌────────────────────┐      │
              |   │ divide by 16       │      │
              |   └────────┬───────────┘      │
              |            └──> baud_tick_1x  │
              |                               ↓
              |                      Reset (rst_c)
              +---------------------------+
```

---

## Formula

```
baud_rate = clk_freq / (16 × baud_div)
```

This design assumes 16× oversampling, which is standard in most UART receivers.

---

## Example Configuration

If:

* `clk_freq = 50 MHz`
* `baud_rate = 9600`

Then:

```
baud_div = 50_000_000 / (16 × 9600) ≈ 326
```

Use an external 16-bit counter that:

* Increments every system clock cycle
* Resets when `rst_c` is asserted

---

## Output Timing

| Clock Cycle | count | baud\_tick\_16x | baud\_tick\_1x | rst\_c |
| ----------- | ----- | --------------- | -------------- | ------ |
| 324         | 324   | 0               | 0              | 1      |
| 325         | 325   | 0               | 0              | 1      |
| 326         | 326   | 1               | maybe 1        | 0      |
| 327         | 0     | 0               | 0              | 1      |

* `baud_tick_16x` goes high for 1 clock cycle every `baud_div` clocks.
* `baud_tick_1x` goes high every 16 `baud_tick_16x` pulses.
* `rst_c` goes low when count reaches `baud_div - 2`, signaling counter reset.

---

## Integration Use Case

Use this module to:

| Tick            | Used By | Purpose                          |
| --------------- | ------- | -------------------------------- |
| `baud_tick_16x` | RX      | Oversampling for start/data bits |
| `baud_tick_1x`  | TX      | Precise timing for bit transfer  |

---

## File Structure

| File                | Description                       |
| ------------------- | --------------------------------- |
| `baud_gen_16x.v`    | Verilog module source             |
| `tb_baud_gen_16x.v` | Testbench with counter simulation |



