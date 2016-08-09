//
//  daemon_init.h
//  ibr-dtn
//
//  Created by Chen Yang on 7/21/16.
//  Copyright © 2016 Chen Yang. All rights reserved.
//

#ifndef daemon_init_h
#define daemon_init_h

#ifdef  __cplusplus
extern "C" {
#endif

  int init_ibrdtn_daemon(int argc, char *argv[]);
  int init_daemon_thread();
  int shutdown_daemon();
  int revoke_daemon();
    
#ifdef __cplusplus
};
#endif

#endif /* daemon_init_h */

