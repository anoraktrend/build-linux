Build yourself a Linux
======================

% TODO explain Makefile

Abstract
--------

*This started out as a personal project to build a very small Linux based
operating system that has very few moving parts but is still very complete and
useful. Along the way of figuring out how to get the damn thing to boot and
making it do something useful I learned quite alot. Too much time has been
spent reading very old and hard to find documentation, or when there was none
the source code of how other people were doing it. So I thought, why not share
what I have learned.*

The Linux Kernel
----------------

The core component of our operating system, the kernel, that which manages the
processes and talks to the hardware on our behalf. You can retrieve a copy of
the source code easily from [kernel.org](https://www.kernel.org/). There are
multiple versions to choose from, choosing one is usually a tradeoff between
stability and wanting newer features. If you look at the
[Releases](https://www.kernel.org/category/releases.html) tab, you can see how
long each version will be supported and keeps receiving updates. So you can
usually just apply the update or use the updated version without changing
anything else or having something break.

So just pick a version and download the tar.xz file and extract it with ``tar
-xf linux-version.tar.xz``. To build the kernel we obviously need a compiler and
some build tools. Installing ``build-essential`` on Ubuntu (or ``base-devel`` on
Arch Linux) will almost give you everything you need. You'll also need to
install ``bc`` for some reason.

The next step is configuring you build, inside the untarred directory you do
``make defconfig``. This will generate a default config for your currect
architecture and place it in ``.config``. You can edit it directly with a text
editor but it's much better to do it with an interface by doing ``make nconfig``
(this needs ``libncurses5-dev`` on Ubuntu). Here you can enable/disable features
and device drivers with the spacebar. ``*`` means that it will be compiled in
your kernel image. ``M`` means it will be compiled inside a seprate kernel
module. Which is a part of the kernel that will be put in a seperate file and
can be loaded in dynamically in the kernel when they are required. The default
config will do just fine for basic stuff like running in a virtual machine. But
in our case, we don't really want to deal with kernel modules so we'll just do
this: ``sed "s/=m/=y/" -i .config``. Building the kernel is now just running
``make``. Don't forget to add ``-jN`` with `N` the number of cores of this might
take a while.

Other useful/interesting ways to configure the kernel are:

  * ``make localmodconfig`` will look at the modules that are currently
      loaded in the running kernel and change the config so that only those are
      enabled as module. Useful for when you only want to build the things you
      need without having to figure out what that is. % TODO LSMOD and caveat

  * ``make localyesconfig``,the same as above but everything gets compiled in
      the kernel instead as a kernel module.

  * ``make allmodconfig`` generates a new config where all options are enabled
      and as much as possible as module.

  * ``make allyesconfig``, same as above but with everything compiled in the
      kernel.

  * ``make randconfig`` generates a random config...

Busybox Userspace
-----------------

All these tools you know and love like ``ls``, ``echo``, ``cat`` ``mv`` and
``rm`` and so on. Which are commenly referred to as the 'coreutils'. It has that
and alot more, like utilities from ``util-linux`` so we can do stuff like
``mount`` and even a complete init system. Basicly most tools to expect to be
present on a Linux system only are these somewhat simplified.

You can get the source from [busybox.net](https://busybox.net/). They also
provide prebuilt binaries which will do just fine for most use-cases. But just
to be sure we will build our own version.

Configuring busybox is very similar to configuring the kernel. It also uses a
``.config`` file and you can do ``make defconfig`` to generate one. But we are
going to use the one I provided (which I stole from Arch Linux). You can find
the config in this git repo with the name ``bb-config``. Like the ``defconfig``
version, this has most utilities enabled but with a few differences.

The C Standard Library
----------------------

The C standard library is more important to the operating system than you might
think. It provides some useful functions and an interface to the kernel. But it
also handles DNS requests and provides a dynamic linker. We don't really have to
pay attention to any of this, we can just statically link the one we are using
right know which is probably 'glibc'. This means the following part is optional.
But I thought this would make it more interesting and it also makes us able to
build smaller binaries.

That's because we are going to use [musl](https://www.musl-libc.org/), which is
a lightweight libc implementation. You can get it by installing ``musl-tools``
on Ubuntu or simply ``musl`` on Arch Linux. Now we can link binaries to musl
instead of glibc by using ``musl-gcc`` instead of ``gcc``.