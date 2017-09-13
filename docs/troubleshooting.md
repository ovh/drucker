## Network: IP already in use
This error is shown because you try to use a command (like Drush) with the stack stopped (make stop). You need to either re-run the stack (```make start```), or shutdown it.

## Network: Why IPv6 is disabled?
The IPv6 is disabled inside containers, due to internal side effects (see Docker images).

## *command* not found
Please "source" the "load-env" file before.
```bash
$ cd drucker
$ source load-env
```

---
