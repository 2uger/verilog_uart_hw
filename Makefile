VIVADO_BUILD_DIR = vivado_build
TEST_DIR = tb

build:
	@echo "Build whole vivado project."
	$(MAKE) -C $(VIVADO_BUILD_DIR) build

build_clean:
	@echo "Remove all artifacts after build, remove logs."
	$(MAKE) -C $(VIVADO_BUILD_DIR) clean
	rm -rf *.jou *.log

test:
	@make -C $(TEST_DIR)

