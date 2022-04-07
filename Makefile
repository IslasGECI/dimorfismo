all: tests reports/funcion_logistica.pdf

define lint
	R -e "library(lintr)" \
	  -e "lint_dir('R', linters = with_defaults(line_length_linter(100)))" \
	  -e "lint_dir('src', linters = with_defaults(line_length_linter(100)))" \
	  -e "lint_dir('tests/testthat', linters = with_defaults(line_length_linter(100)))"
endef

define runScript
	mkdir --parents $(@D)
	R --file=$<
endef

# I. Sección de variables
# ------------------------------------------------------------------------------------------------

csvBestModelTable = \
	data/processed/best_models_table.csv

csvLogisticModelTable = \
	data/processed/logistic_model_table.csv

jsonBestLogisticModelParameters = \
	data/processed/best_logistic_model_parameters_laal_ig.json

jsonLogisticModelParameters = \
	data/processed/logistic_model_parameters.json

RawData = \
	data/raw/datapackage.json \
	data/raw/laysan_albatross_morphometry_guadalupe.csv

# II. Sección de requisitos de objetivos principales:
# ------------------------------------------------------------------------------------------------
reports/funcion_logistica.pdf: reports/logistic_function.tex $(csvLogisticModelTable) $(csvBestModelTable) $(jsonBestLogisticModelParameters) $(jsonLogisticModelParameters)
	cd $(<D) && pdflatex $(<F)
	cd $(<D) && pythontex $(<F)
	cd $(<D) && pdflatex $(<F)
	cd $(<D) && pdflatex $(<F)

# III. Sección de dependencias para los objetivos principales
# ------------------------------------------------------------------------------------------------
$(csvLogisticModelTable): src/01_create_parameter_logistic_model_LAAL.R $(RawData) R/dimorphism_model_class.R R/calculator_roc_class.R R/regretion_to_data_frame_coefficients_function.R
	$(runScript)

$(csvBestModelTable) $(jsonBestLogisticModelParameters): src/02_evaluate_better_models.R $(RawData) $(csvLogisticModelTable) R/dimorphism_model_class.R R/calculator_roc_class.R
	$(runScript)

$(jsonLogisticModelParameters): src/03_predict_sex.R $(RawData) $(csvBestModelTable) R/dimorphism_model_class.R R/calculator_roc_class.R
	$(runScript)

# IV. Sección del resto de los phonies
# ------------------------------------------------------------------------------------------------
.PHONY:
	all \
	check \
	clean \
	coverage \
	format \
	install \
	install \
	linter \
	tests

check: linter

clean:
	rm --force --recursive data/processed
	rm --force --recursive dimorfismo.Rcheck
	rm --force --recursive man
	rm --force --recursive reports/pythontex*
	rm --force *.tar.gz
	rm --force reports/*.aux
	rm --force reports/*.log
	rm --force reports/*.pdf
	rm --force reports/*.pytxcode
	rm --force NAMESPACE

coverage: $(jsonLogisticModelParameters)
	R -e "covr::package_coverage()"

format:
	R -e "library(styler)" \
	  -e "style_dir('src')" \
	  -e "style_dir('R')" \
	  -e "style_dir('tests')"

install:
	R -e "devtools::document()" && \
    R CMD build . && \
    R CMD check dimorfismo_0.1.0.tar.gz && \
    R CMD INSTALL dimorfismo_0.1.0.tar.gz

linter:
	$(lint)
	$(lint) | grep -e "\^" && exit 1 || exit 0

tests: $(jsonLogisticModelParameters)
	R -e "devtools::test()"
