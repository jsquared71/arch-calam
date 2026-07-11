.PHONY: calamares iso clean validate

calamares:
	./scripts/prepare-calamares.sh

iso:
	sudo ./scripts/build-iso.sh

clean:
	sudo ./scripts/build-iso.sh --clean-only

validate:
	./scripts/validate.sh
