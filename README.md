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

## Objetivos en el Proyecto de Vinculación con Valor en Créditos 2020-1

### Objetivos a corto plazo:

- [ ] Desarrollar archivo Makefile para poder reenderizar PDF a partir de resultados en src.
- [ ] Mostrar en el PDF los resultados obtenidos en los archivos .csv y .json .
- [ ] Redactar un reporte semanal con las actividades realizadas declarando su intensión u objetivo.

### Objetivos a largo plazo:

- [ ] Refactorizar programas principales en R.
- [ ] Publicar un PDF detallando la parte matemática del *artículo de Dimorfismo* en la plataforma de arXiv.
- [ ] Reporte final con base en reportes semanales.
