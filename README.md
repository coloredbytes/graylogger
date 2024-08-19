<p align="center">
  <img src="./assets/images/github-header-image.png" alt="Header">
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
  </a>
</p>

# :link: Table of Contents

+ [:link: Table of Contents](#%3A%6C%69%6E%6B%3A%2D%74%61%62%6C%65%2D%6F%66%2D%63%6F%6E%74%65%6E%74%73)
  + [:x: Problem](#%3A%78%3A%2D%70%72%6F%62%6C%65%6D)
  + [:heavy\_check\_mark: Solution](#%3A%68%65%61%76%79%5F%63%68%65%63%6B%5F%6D%61%72%6B%3A%2D%73%6F%6C%75%74%69%6F%6E)
  + [:gear: Instructions](#%3A%67%65%61%72%3A%2D%69%6E%73%74%72%75%63%74%69%6F%6E%73)
  + [:memo: Notes](#%3A%6D%65%6D%6F%3A%2D%6E%6F%74%65%73)


## :x: Problem

I've used [**Graylog**](https://graylog.org/) for about a year and loved it. The issue is I don't like to copy pasta commands and prefer to install a base via a script and configure it.

## :heavy_check_mark: Solution

The Answer to that is **Graylogger**. I created this script to Automate the process and get a nice clean base setup to configure to my needs as I go on. 

## :gear: Instructions

- Clone the Repo.

```bash
git clone https://github.com/ColoredBytes/graylogger.git
```
- Run the script.

```bash
./Graylogger/install.sh
```



## :memo: Notes
> [!CAUTION]
> This a RPM Based script will not work on Ubutnu ATM. Till I find time to work on that part.

>[!NOTE]
> You will still need to configure `/etc/opensearch/opensearch.yml` and `/etc/graylog/server/server.conf` and possibly `/etc/opensearch/jvm.options`. I have it set to 8GB of Ram as that half of the recconmnded amount of RAM.
> - You can find info on this [here](https://go2docs.graylog.org/current/downloading_and_installing_graylog/red_hat_installation.htm?tocpath=Installing%20Graylog%7COperating%20System%20Packages%7C_____2).
