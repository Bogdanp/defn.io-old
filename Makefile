_site: css posts templates *.md index.html
	stack exec blog build

.PHONY: deploy
deploy: _site
	gcloud app deploy --project defn-166408 app.yaml
