build:
	xcodebuild -target BuildAll -configuration Release build
# install:
# 	xcodebuild -target BuildAll clean install DSTROOT=${HOME}
# 別のユーザーでテスト/スクリーンショットを撮るために、ローカルドメインにインストールする。
install:
	xcodebuild -target BuildAll clean install DSTROOT=/
