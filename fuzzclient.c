#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>

void error(const char *msg)
{
        perror(msg);
        exit(1);
}

int main(int argc, char *argv[])
{
        int clientsock, newclientsock, portno;
        socklen_t clilen;
        char buffer[256];
        struct sockaddr_in serv_addr, cli_addr;
        int n;
        if (argc < 3) {
               fprintf(stderr,"ERROR, no port provided\n");
               exit(1);
        }
        clientsock = socket(AF_INET, SOCK_STREAM, 0);
        if (clientsock < 0) error("ERROR opening socket");
        int opt = 1;
        if (setsockopt(clientsock, SOL_SOCKET, SO_REUSEADDR,
                (char *)&opt, sizeof(opt)) < 0)
                        error("ERROR on setsockopt");
        controlsock = socket(AF_INET, SOCK_STREAM, 0);
        if (controlsock < 0) error("ERROR opening socket");
        int opt = 1;
        if (setsockopt(controlsock, SOL_SOCKET, SO_REUSEADDR,
                (char *)&opt, sizeof(opt)) < 0)
                        error("ERROR on setsockopt");
        bzero((char *) &serv_addr, sizeof(serv_addr));
        portno = atoi(argv[1]);
        serv_addr.sin_family = AF_INET;
        serv_addr.sin_addr.s_addr = INADDR_ANY;
        serv_addr.sin_port = htons(portno);
        if (bind(clientsock, (struct sockaddr *) &serv_addr,
                sizeof(serv_addr)) < 0) 
                error("ERROR on binding");
        listen(clientsock,5);
        clilen = sizeof(cli_addr);
        while (1) {
                newclientsock = accept(clientsock, 
                   (struct sockaddr *) &cli_addr, &clilen);
                if (newclientsock < 0) error("ERROR on accept");
                printf("Client connected from %s:%i\n", 
                        inet_ntoa(cli_addr.sin_addr.s_addr), cli_addr.sin_port);
                bzero(buffer,256);
                while (1) {
                        n = read(newclientsock,buffer,255);
                        if (n < 0) error("ERROR reading from socket");
                        else if (!n) {
                                break;
                        }
                }
                close(newclientsock);
                printf("Client disconnected\n");
        }
        close(clientsock);
        return 0; 
}
