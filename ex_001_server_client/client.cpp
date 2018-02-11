#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

char message[] = "Hello my asm server!";
char buf[1024];

int main () {
  int sock;
  struct sockaddr_in saddr;
  saddr.sin_family = AF_INET;
  saddr.sin_port = htons(2458);
  saddr.sin_addr.s_addr = inet_addr("127.0.0.1");
  sock = socket (AF_INET, SOCK_STREAM, 0);
  if (sock < 0) {
    printf ("socket error\n");
    return 0;
  }
  if (connect (sock, (struct sockaddr *)&saddr, sizeof (saddr)) < 0) {
    printf ("connect error\n");
    return 0;
  }
  
  char len = strlen(message);
  send (sock, &len, 1, 0);
  send (sock, message, sizeof(message), 0);
//  recv (sock, buf, sizeof (buf), 0);

//  printf ("%s\n", buf);
  close (sock);

  return 0;
}
