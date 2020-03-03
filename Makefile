build:
	xcodebuild -target BuildAll -configuration Release build
# install:
# 	xcodebuild -target BuildAll clean install DSTROOT=${HOME}
# 別のユーザーでテスト/スクリーンショットを撮るために、ローカルドメインにインストールする。
install: clean
	xcodebuild -target BuildAll install DSTROOT=/

installonly:
	xcodebuild -target BuildAll install DSTROOT=/
	
clean:
	xcodebuild -target BuildAll clean
