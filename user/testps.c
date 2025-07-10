#include "kernel/types.h"
#include "user/user.h"

#define DEPTH 5
#define ITERATIONS 100
#define N_FORKS 10

// Basic functionality tests
void basic_test() {
    printf("\n### TEST 1: Basic Process Tree ###\n");
    printf("Expected: At least init, sh, and test_pstree\n");
    pstree();
}

// Fork hierarchy test
void fork_test() {
    printf("\n### TEST 2: Fork Hierarchy ###\n");
    printf("Creating %d-level process tree...\n", DEPTH);
    
    for (int i = 0; i < DEPTH; i++) {
        if (fork() == 0) {
            printf("Child %d created\n", getpid());
        } else {
            wait(0);
            break;
        }
    }
    pstree();
}

// Zombie process test
void zombie_test() {
    printf("\n### TEST 3: Zombie Processes ###\n");
    int pid = fork();
    if (pid == 0) {
        printf("Child %d exiting (will become zombie)\n", getpid());
        exit(0);
    } else {
        sleep(5); // Allow child to become zombie
        printf("Parent %d not waiting (zombie child should appear)\n", getpid());
        pstree();
        wait(0); // Clean up zombie
    }
}

// Stress test
void stress_test() {
    printf("\n### TEST 4: Stress Test (%d processes) ###\n", N_FORKS);
    int pids[N_FORKS];
    
    for (int i = 0; i < N_FORKS; i++) {
        pids[i] = fork();
        if (pids[i] == 0) {
            sleep(100); // Child stays alive
            exit(0);
        }
    }
    
    pstree();
    
    // Cleanup
    for (int i = 0; i < N_FORKS; i++) {
        kill(pids[i]);
    }
    while (wait(0) != -1);
}

// Performance benchmark
void benchmark() {
    printf("\n### TEST 5: Performance Benchmark ###\n");
    printf("Running pstree %d times...\n", ITERATIONS);
    
    uint start = uptime();
    for (int i = 0; i < ITERATIONS; i++) {
        pstree();
    }
    uint end = uptime();
    uint total_ticks = end - start;
    uint num = total_ticks / ITERATIONS;
    uint frac = (total_ticks % ITERATIONS) * 1000 / ITERATIONS;
    printf("Results:\n");
    printf("- Total ticks: %d\n", end-start);
    printf("- Average ticks per call: %d.%d ms\n", num, frac);
}

// Main test runner
int main() {
    printf("Starting pstree syscall evaluation\n");
    
    basic_test();
    fork_test();
    zombie_test();
    stress_test();
    benchmark(); 
    
    printf("\nAll tests completed!\n");
    exit(0);
}