# Dimorfismo Sexual de Albatros de Laysan

```shell
rm --force --recursive dimorfismo
git clone https://github.com/IslasGECI/dimorfismo
docker build --no-cache --tag islasgeci/dimorfismo:latest .
docker run --rm --volume ${PWD}:/workdir islasgeci/dimorfismo:latest make
```
