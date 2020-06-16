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
BRANCH='nombre/rama'
REMOTE='andrea-sanchez'
REPO='dimorfismo'
rm --force --recursive ${REPO}
git clone https://github.com/${REMOTE}/${REPO}
cd ${REPO}
git checkout ${BRANCH}
docker build --no-cache --tag ${REMOTE}/${REPO}:latest .
docker run --rm --volume ${PWD}:/workdir ${REMOTE}/${REPO}:latest make
```

## Objetivos

### Pendientes:

- [ ] Cubrir el código con pruebas.
- [ ] Refactorizar programas principales en R.
- [ ] Publicar nota en [arXiv](https://arxiv.org/) o [JOSS](https://joss.theoj.org/).

### Terminado:

- [x] Desarrollar archivo Makefile para poder reenderizar PDF a partir de resultados en `src/`.
- [x] Mostrar en el PDF los resultados obtenidos en los archivos CSV y JSON.
- [x] Redactar un reporte semanal con las actividades realizadas declarando su intensión u objetivo.
- [x] Reporte final con base en reportes semanales.
