test:
	which /bin/bash || { echo "please install bash to /bin/bash"; exit 1 ; }
	which base64    || { echo "please install base64";            exit 1 ; }
	which find      || { echo "please install find";              exit 1 ; }
	which sed       || { echo "please install sed";               exit 1 ; }
	which unzip     || { echo "please install unzip";             exit 1 ; }
	which xargs     || { echo "please install xargs";             exit 1 ; }
	which zip       || { echo "please install zip";               exit 1 ; }
	which zstd      || { echo "please install zstd";              exit 1 ; }

install: test
	[ -n "${INSTALL_DIR}" ] || { echo "Usage:\n\tINSTALL_DIR=Directory make install"; exit 1 ; }
	[ -d "${INSTALL_DIR}" ] || { echo "${INSTALL_DIR} not exists";                    exit 1 ; }
	install zipstd.sh "${INSTALL_DIR}/zipstd"
	install unzipstd.sh "${INSTALL_DIR}/unzipstd"
