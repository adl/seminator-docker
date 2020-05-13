# What is this?

This is a docker image that can be used to experiment with [Seminator 2](https://github.com/mklokocka/seminator).  Besides Seminator 2, it contains a copy of [Spot](https://spot.lrde.epita.fr/), [Owl](https://owl.model.in.tum.de/), [Jupyter](https://jupyter.org/), [Roll](https://github.com/ISCAS-PMC/roll-library), [GOAL](http://goal.im.ntu.edu.tw/) (with [the Fribourg plugin](http://goal.im.ntu.edu.tw/wiki/doku.php?id=goal:extensions#fribourg_construction)), and the previous two versions of Seminator: 1.1 (our LPAR'17 paper) and 1.2 (only mentioned during the LPAR'17 presentation), for comparison.
Finally, it contains a copy of [seminator-evaluation](https://github.com/xblahoud/seminator-evaluation), i.e., Jupyter notebooks that compare the results of Seminator 2 with the other installed tools.  This seminator evaluation contains the source of the experimental evaluation presented in our CAV'20 paper titled *Seminator2 Can Complement Generalized Büchi Automata via Improved Semi-Determinization* (by František Blahoudek, Alexandre Duret-Lutz, and Jan Strejček).

For the artifact submission to CAV'20, we opted for docker images over virtual machines as the former are much more lightweight and versatile: you can execute commands that are inside the docker image without having to boot an entire system, work with multiple docker images at the same time, and rebuild them and extend them very easily.  In the following, we assume that Docker is already [installed](https://docs.docker.com/install/) on your computer.


# Downloading the docker image

The image is automatically [built and stored by DockerHub](https://hub.docker.com/r/gadl/seminator), using the [Dockerfile stored on GitHub](https://github.com/adl/seminator-docker).  The easiest way to download it is to run:

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

You may use the docker image in multiple ways.  Below we give some examples.  If you are in a hurry, jump directly to example 5, as this is the preferred one.

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

   NOTE: Using the `--rm=true` option causes Docker to remove the container instance on exit, meaning that any files you create in the container will be lost.  If you do not use this option (the default is `--rm=false`) you can restart a previously exited container with `sudo docker start -a b5d1c544c0df`.  The container's name (in this example `b5d1c544c0df`) is displayed in the prompt of the shell, but can also be found with `sudo docker ps -a`.

2. Running a non-interactive command in the docker image

   ```console
   $ sudo docker run --rm=true -it gadl/seminator bash -c "ltl2tgba 'F(a & GFb) R c' | seminator"
   [...]
   ```

3. Piping some input from outside the container to a command that is inside the docker image

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
   $ sudo docker run --rm=true -it -p 7777:8888 gadl/seminator run-nb
   ```

   Then point your navigator to `http://localhost:7777/lab`.  Note
   that the `-p 7777:8888` redirects the port 8888 of the container to
   the port 7777 of your computer.  If the latter is already used, on
   your computer, use another number.

   Once connected, your navigator should display a file listing
   containing this README file, a `sandbox.ipynb` notebook showing how
   to run all the tools installed in this notebook (see below), a
   subdirectory `notebooks/` linking to the example notebooks of
   seminator, and an `src/` directory containing the sources of
   Seminator 2.0 and its experimental evaluation.

   In addition to replaying those notebooks, or creating new ones, you
   can also start an interactive shell from within your navigator.

   Some users may prefer to use `http://localhost:7777/` (without the
   `/lab` part of the URL) to access the old Jupyter environment.

# Installed tools

Below we give an example of how to run each of the installed tool to perform a task related to seminator (i.e., semi-determinizing an automaton, or complementing it).  We assume you are running these command using an interactive shell running in the container image (as started in point 1 of previous section, or using a terminal in the Jupyter environment, as in point 5 of the previous section).

Some of the tools assume that a file can only contain one automaton, while other are able to work over all automata present in a file.  To work with the lowest common denominator, that example will process one automaton at a time, but the description of each command will use the plural in case it would work with multiple automata.

The example are ordered so that they can depend on files produced by examples above them.

1. [Spot 2.9](https://spot.lrde.epita.fr/) was installed in `/usr/bin` from its Debian package.  This package provides a library of ω-automata algorithms (on which Seminator is built), a [set of tools](https://spot.lrde.epita.fr/tools.html) for manipulating automata from the command-line, and Python bindings.  The following commands may be useful:

   - `ltl2tgba 'F(a & GFb) R c' >automaton.hoa` converts an LTL formula into an equivalent generalized-Büchi automaton
   - `ltl2tgba -B 'F(a & GFb) R c' >sba.hoa` converts an LTL formula into an equivalent state-based Büchi automaton
   - `autfilt -c --is-semi-deterministic automaton.hoa` counts the number of semi-deterministic automata in file `automaton.hoa` (in this example it would output 0).
   - `autfilt --tgba --complement automaton.hoa >complement.hoa` complements the automata in file `automaton.hoa` and output (maybe generalized) Büchi automata in `complement.hoa`.   (Depending on the type of the input, the complementation is done using various strategies, but currently this does not uses the NCSB-complementation for semi-deterministic automata, even if there is an implementation of that in Spot.)
   - `autfilt -B automaton.hoa >sba.hoa` convert all the automata in `automaton.hoa` into state-based Büchi automata saved in `sba.hoa`
   - `autfilt --small automaton.hoa >smaller.hoa` simplify all automata `automaton.hoa`, and save the result in `smaller.hoa`

2. [Seminator 2.0](https://github.com/mklokocka/seminator/) was compiled and installed in `/usr/local/bin`.  A copy of its source-code is in `~/src/seminator-2.0/`.

   - `seminator automaton.hoa >semidet.hoa` will semi-determinize the automata in `automaton.hoa` and output the result in `semidet.hoa`
   - `seminator --complement=spot automaton.hoa >complement.hoa` will first semi-determinize the automata and then apply Spot's implementation of the NCSB complementation algorithm, outputting the results in `complement.hoa`.
   - `seminator --complement=pldi automaton.hoa >complement.hoa` does the same, but using the PLDI variant of the NCSB complementation (which is implemented in seminator).

3. [Seminator 1.1 and 1.2](https://github.com/mklokocka/seminator/) are installed in `/usr/local/bin/` as `seminator-1.1` and `seminator-1.2`.  For instance:

   - `seminator-1.2 automaton.hoa >semidet.hoa` will semi-determinize the automaton in `automaton.hoa`

   These versions do not support complementation, and will only process one automaton at a time.

4. [Owl 19.06.03](https://owl.model.in.tum.de/) was installed in `/usr/local/{share,bin}/`.  This is a Java library for ω-automata manipulation, and like spot, it installs many command-line tools.   The following commands are related to seminator:

   - `ltl2ldgba 'F(a & GFb) R c' >semidet.hoa` builds a semi-deterministic generalized-Büchi automaton from an LTL formula
   - `ltl2ldgba -s 'F(a & GFb) R c' >semidet.hoa` is a "symmetric" variant of this construction
   - `nba2ldba -I automaton.hoa >semidet.hoa` builds a semi-deterministic automaton from `automaton.hoa`

5. [ROLL 1.0](https://github.com/ISCAS-PMC/roll-library) (Regular $\omega$-automata Learning Library) was installed in `/usr/local/{share,bin}/`.  This is Java library with a command-line interface.  For simplicity, we have installed a script called `roll`.

   - `roll complement automaton.hoa -out complement.hoa` will read `automaton.hoa` and output its complement in `complement.hoa`; this replaces the [Buechic tool](https://iscasmc.ios.ac.cn/buechic/doku.php).

6. [GOAL-20200506](http://goal.im.ntu.edu.tw/) GOAL stands for Graphical Tool for Omega-Automata and Logics.  The docker image contains a "headerless" version of the Java runtime, enough to run GOAL from the command-line, but not to start its graphical interface.  Additionally, [the Fribourg plugin](http://goal.im.ntu.edu.tw/wiki/doku.php?id=goal:extensions#fribourg_construction)) provides a new complementation implementation.

   - `gc batch '$temp = complement -m fribourg sba.hoa; save -c HOAF $temp complement.hoa;'` will complement the state-based Büchi automaton stored in `sba.hoa` using the Fribourg construction, and will save the result in `complement.hoa`.
   - `gc batch '$temp = complement -m piterman -eq -sp sba.hoa; save -c HOAF $temp complement.hoa;'` does the same using the Piterman construction


The `sandbox.ipynb` Jupyter notebook at the root of the directory contains definitions for Python functions that can help run all these tools interactively.

# Experimental evaluation

A copy of the scripts used for performing the experimental evaluation of Seminator 2 are in the `~/src/seminator-evalution/` directory.  The easiest way to work with this is via Jupter Lab.  Start it with:

   ```console
   $ sudo docker run --rm=true -it -p 7777:8888 gadl/seminator run-nb
   ```

The connect you web browser to `http://localhost:7777/lab/tree/src/seminator-evaluation/`.
In the left panel, right-click on the `README.md` file and select *open with > Markdown preview*.
After reading those instructions, open the notebooks you would like to read or replay.

Should you want to dig into what is going on during the evaluation, the `src/` directory contains a copy of the source code for `ltlcross_wrapper`, which is used to simplify (and speed up) the evaluation.
