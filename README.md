#   Dockerize gg.docpatch.org

This repository gives you an insight how to build and run our website [gg.docpatch.org](https://gg.docpatch.org/).

##  About DocPatch

tl;dr: [We put the complete "Grundgesetz" of Germany under version control and published it.](https://wiki.chaospott.de/DocPatch/Grundgesetz) (German)

##  Helpful resources

-   [The website itself](https://gg.docpatch.org/)
-   [Compiled Grundgesetz with every change since the beginning on 1949-05-23](https://github.com/c3e/grundgesetz)
-   [Project repository of the Grundgesetz](https://github.com/c3e/grundgesetz-dev)
-   [Project repository of the website](https://github.com/c3e/grundgesetz-web)
-   [DocPatch toolchain](https://github.com/c3e/docpatch)

##  Who we are

We are part of the Open Data movement and support the [Open Definition](http://opendefinition.org/od/2.1/en/). **Our way** is to "hack" on documents and build Free Software around them – **our goal** is to bring open data to governments – **our idea** is to re-publish constitutions, law texts, and any other public documents in a way every human being or any machine may use them.

##  Background

To build and run our website we use Docker. As you can see in the [`Dockerfile`](Dockerfile), we build a multi-stage image. First, we install all required tools, clone all relevant repositories, compile the Grundgesetz, and then integrate it into the Web site. Last, we put the website with all files into a second image running Nginx as a Web server. A multi-stage image gives us the opportunity to share and run a small image which only contains the data needed for the Web site – nothing more.

##  Requirements

-   Docker, of course
-   While building the first stage you'll need an Internet connection, plenty of time and ~ 5 GByte of free space
-   The final image needs less than 200 MBytes

##  Build

~~~ {.bash}
docker build . -t docpatch-grundgesetz-web
~~~

##  Run

~~~ {.bash}
docker run -p 80:80 docpatch-grundgesetz-web
~~~

Then, open http://localhost/ in your Web browser.

##  Copyright

Copyright (C) 2019 [Benjamin Heisig](https://benjamin.heisig.name/). License [GPLv3+: GNU GPL version 3 or later](https://www.gnu.org/licenses/gpl.html). This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
