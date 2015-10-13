{-# LANGUAGE OverloadedStrings #-}

import           Hakyll


main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "about.org" $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archive"             `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    create ["atom.xml"] $ do
        route idRoute
        compile $
          loadAllSnapshots "posts/*" "content"
            >>= fmap (take 10) . recentFirst
            >>= renderAtom feedConfiguration feedCtx

    create ["rss.xml"] $ do
        route idRoute
        compile $
          loadAllSnapshots "posts/*" "content"
            >>= fmap (take 10) . recentFirst
            >>= renderRss feedConfiguration feedCtx

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- (return . take 10) <$> (recentFirst =<< loadAll "posts/*")
            let indexCtx =
                    listField "posts" postCtx posts   `mappend`
                    constField "title" "Recent posts" `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext


feedCtx :: Context String
feedCtx =
    postCtx `mappend`
    bodyField "description"


feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
  { feedTitle = "defn.io"
  , feedDescription = ""
  , feedAuthorName = "Bogdan Popa"
  , feedAuthorEmail = "bogdan@defn.io"
  , feedRoot = "http://defn.io"
  }
