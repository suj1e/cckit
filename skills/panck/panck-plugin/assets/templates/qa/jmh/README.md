# JMH Microbenchmarks

Java Microbenchmark Harness for code-level performance testing.

## Structure

```
jmh/
├── src/jmh/java/           # Benchmark source files
└── README.md
```

## Run Benchmarks

```bash
# From project root
./gradlew jmh

# Specific benchmark
./gradlew jmh --tests "*StringBenchmark*"
```

## Create Benchmark

```java
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@State(Scope.Benchmark)
public class MyBenchmark {

    @Benchmark
    public void benchmarkMethod() {
        // Code to benchmark
    }
}
```

## Profiling

```bash
# With async profiler
./gradlew jmh -Pjmh.profiler=async

# With GC profiler
./gradlew jmh -Pjmh.profiler=gc
```
