# Dimorfismo Sexual de Albatros de Laysan en Isla Guadalupe

Para reproducir lo que se encuentra en el repo oficial:

```shell
rm --force --recursive dimorfismo
git clone https://github.com/IslasGECI/dimorfismo
cd dimorfismo
docker build --no-cache --tag islasgeci/dimorfismo:latest .
docker run --rm --volume ${PWD}:/workdir islasgeci/dimorfismo:latest make
```

Para examinar un _fork_:

```shell
FORK='andrea-sanchez'
RAMA='feature/scriptsR'
rm --force --recursive dimorfismo
git clone https://github.com/${FORK}/dimorfismo
cd dimorfismo
git checkout ${RAMA}
docker build --no-cache --tag ${FORK}/dimorfismo:latest .
docker run --rm --volume ${PWD}:/workdir ${FORK}/dimorfismo:latest make
```
