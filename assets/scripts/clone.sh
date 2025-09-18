#!/bin/sh

echo "Cloning repositories..."

GITHUB=$HOME/Code/GitHub
GITLAB=$HOME/Code/GitLab

if [[ ! -d $GITHUB ]] ; then
  mkdir -p $GITHUB
fi

if [[ ! -d $GITLAB ]] ; then
  mkdir -p $GITLAB
fi

echo ""
echo "=== URL shortener repositories ==="
echo ""

if [[ ! -d "$GITHUB/zainfathoni/shortener" ]] ; then
  git clone git@github.com:zainfathoni/shortener.git $GITHUB/zainfathoni/shortener
  cd $GITHUB/zainfathoni/shortener
  pnpm install
fi

if [[ ! -d "$GITHUB/zainfathoni/rbagi.id" ]] ; then
  git clone git@github.com:zainfathoni/rbagi.id.git $GITHUB/zainfathoni/rbagi.id
  cd $GITHUB/zainfathoni/rbagi.id
  pnpm install
fi

if [[ ! -d "$GITHUB/imas-sg/s.imas.sg" ]] ; then
  git clone git@github.com:imas-sg/s.imas.sg.git $GITHUB/imas-sg/s.imas.sg
  cd $GITHUB/imas-sg/s.imas.sg
  pnpm install
fi

if [[ ! -d "$GITLAB/kawalcovid19/website/kcov.id" ]] ; then
  git clone git@gitlab.com:kawalcovid19/website/kcov.id.git $GITLAB/kawalcovid19/website/kcov.id
  cd $GITLAB/kawalcovid19/website/kcov.id
  pnpm install
fi

if [[ ! -d "$GITHUB/frontend-id/s.feid.dev" ]] ; then
  git clone git@github.com:frontend-id/s.feid.dev.git $GITHUB/frontend-id/s.feid.dev
  cd $GITHUB/frontend-id/s.feid.dev
  pnpm install
fi

if [[ ! -d "$GITHUB/reactjs-id/shortlinks" ]] ; then
  git clone git@github.com:reactjs-id/shortlinks.git $GITHUB/reactjs-id/shortlinks
  cd $GITHUB/reactjs-id/shortlinks
  pnpm install
fi

if [[ ! -d "$GITHUB/zainfathoni/bapakcerdas.com" ]] ; then
  git clone git@github.com:zainfathoni/bapakcerdas.com.git $GITHUB/zainfathoni/bapakcerdas.com
  cd $GITHUB/zainfathoni/bapakcerdas.com
  pnpm install
fi
