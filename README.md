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
BRANCH='feature/tarea'
REMOTE='andrea-sanchez'
REPO='dimorfismo'
rm --force --recursive ${REPO}
git clone https://github.com/${REMOTE}/${REPO}
cd ${REPO}
git checkout ${BRANCH}
docker build --no-cache --tag ${REMOTE}/${REPO}:latest .
docker run --rm --volume ${PWD}:/workdir ${REMOTE}/${REPO}:latest make
```

## Objetivos en el Proyecto de Vinculación con Valor en Créditos 2020-1

### Objetivos a corto plazo:

- [x] Desarrollar archivo Makefile para poder reenderizar PDF a partir de resultados en src.
- [ ] Mostrar en el PDF los resultados obtenidos en los archivos .csv y .json .
- [ ] Redactar un reporte semanal con las actividades realizadas declarando su intensión u objetivo.

### Objetivos a largo plazo:

- [ ] Refactorizar programas principales en R.
- [ ] Publicar un PDF detallando la parte matemática del *artículo de Dimorfismo* en la plataforma de [arXiv](https://arxiv.org/).
- [ ] Reporte final con base en reportes semanales.
- [ ] Cubrir el código con pruebas.
