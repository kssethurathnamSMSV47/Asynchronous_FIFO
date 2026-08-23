# Asynchronous FIFO

## Architecture

![Asynchronous FIFO Architecture](images/async_fifo_architecture.png)

## RTL Design

The FIFO uses:

- Gray-coded pointers
- Two-flop synchronizers
- Independent read/write clocks
- Full and empty flag generation
