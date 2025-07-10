#include "kernel/types.h"
#include "user/user.h"

int main() {
    int pid = fork();
    
    if(pid == 0) 
    {
        // Child process
        exit(0);
    } else 
    
    {
        // Parent process
        pstree();
        // Keep parent alive but responsive
        int cnt=5;
        while(1 && cnt) 
        {
            sleep(50);
            pstree();
            cnt--;
        }
    }
    return 0;
}