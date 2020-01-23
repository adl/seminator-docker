

# What is this?

This is a docker image that can be used to experiment with [Seminator 2](https://github.com/mklokocka/seminator).  Besides seminator, it contains a copy of [Spot](https://spot.lrde.epita.fr/), [Owl](https://owl.model.in.tum.de/), [Jupyter](https://jupyter.org/), [Roll](https://github.com/ISCAS-PMC/roll-library), and [GOAL](http://goal.im.ntu.edu.tw/) (with [the Fribourg plugin](http://goal.im.ntu.edu.tw/wiki/doku.php?id=goal:extensions#fribourg_construction)).

We prefer docker images over virtual machines as the former are much more lightweight and versatile: you can execute commands that are inside the docker image without having to boot an entire system, work with multiple docker images at the same time, and rebuild them and extend them very easily.


# Downloading the docker image

The image is automatically [built and stored by DockerHub](https://hub.docker.com/repository/docker/gadl/seminator), using the [Dockerfile stored on GitHub](https://github.com/adl/seminator-docker).  The easiest way to download it is to run:

```console
$ sudo docker pull gadl/seminator
```

# Rebuilding the docker image

As an alternative to downloading the above pre-built image, you may re-build it from its source.  To do that, run:

```console
$ git clone https://github.com/adl/seminator-docker.git
$ cd seminator-docker
$ sudo docker build -t gadl/seminator .
```

# Running the docker image

You may use the docker image in multiple ways.  Below we give some examples.

1. Running an interactive shell inside the docker image, in order to play with any of the installed tools:

   ```console
   $ sudo docker run --rm=true -it gadl/seminator bash
   95aa1de7b2a8:~$ ltl2tgba 'F(a & GFb) R c' | seminator
   HOA: v1
   name: "sDBA for F(a & GFb) R c"
   States: 4
   Start: 0
   AP: 3 "c" "a" "b"
   acc-name: Buchi
   Acceptance: 1 Inf(0)
   properties: trans-labels explicit-labels trans-acc semi-deterministic
   --BODY--
   State: 0
   [0] 0
   [0] 1
   [0&1] 2
   [0&!1] 3
   State: 1
   [0] 1 {0}
   State: 2
   [!2] 2
   [2] 2 {0}
   State: 3
   [1] 2
   [!1] 3
   --END--
   user@b5d1c544c0df:~$ exit
   ```

   NOTE: Using the `--rm=true` option causes Docker to cleanup the container instance on exit, meaning that any files you create in the container will be lost.  If you do not use this option (the default is `--rm=false`) you can restart a previously exited container with `sudo docker start -a b5d1c544c0df`.  The container's name (in this example `b5d1c544c0df`) is displayed in the prompt of the shell, but can also be found with `sudo docker ps -a`.

2. Running a non-interactive command in the docker image

   ```console
   $ sudo docker run --rm=true -it gadl/seminator bash -c "ltl2tgba 'F(a & GFb) R c' | seminator"
   [...]
   ```

3. Piping some input to a command that is in the docker image

   For instance, assuming you have Spot's `ltl2tgba` installed on your machine (or any other producing automata in the HOA format), you may redirect its output to the containerized version of `seminator` as follows:

   ```console
   $ ltl2tgba 'F(a & GFb) R c' | sudo docker run --rm=true -i gadl/seminator seminator
   [...]
   ```

4. Running a Python3 shell to try the bindings

   ```console
   $ sudo docker run --rm=true -it gadl/seminator python3
   Python 3.7.6 (default, Jan 19 2020, 22:34:52)
   [GCC 9.2.1 20200117] on linux
   Type "help", "copyright", "credits" or "license" for more information.
   ```
   then
   ```pycon
   >>> import spot
   >>> from spot.seminator import seminator
   >>> aut = spot.translate('F(a & GFb) R c')
   >>> print(seminator(aut).to_str())
   HOA: v1
   States: 4
   Start: 0
   AP: 3 "c" "a" "b"
   acc-name: Buchi
   Acceptance: 1 Inf(0)
   properties: trans-labels explicit-labels trans-acc semi-deterministic
   --BODY--
   State: 0
   [0] 0
   [0] 1
   [0&1] 2
   [0&!1] 3
   State: 1
   [0] 1 {0}
   State: 2
   [!2] 2
   [2] 2 {0}
   State: 3
   [1] 2
   [!1] 3
   --END--
   >>> exit()
   ```

5. Starting the Jupyter environment to work with interactive notebooks

   ```console
   $ sudo docker run -p 7777:8888 -t gadl/seminator run-nb
   ```

   Then point your navigator to `http://localhost:7777`.  Note
   that the `-p 7777:8888` redirects the port 8888 of the container to
   the port 7777 of your computer.  If the latter is already used, on
   your computer, use another number.

   Once connected, your navigator should display a file listing
   containing this readme file, and a subdirectory `notebooks/`
   containing the example notebooks of seminator.

   In addition to replaying those notebooks, or creating new ones, you
   can also start an interactive shell from within your navigator.

   You may also try to connect to `http://localhost:7777/lab` instead
   for an alternative environment.
