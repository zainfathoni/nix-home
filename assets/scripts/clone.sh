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
  yarn
fi

if [[ ! -d "$GITHUB/zainfathoni/rbagi.id" ]] ; then
  git clone git@github.com:zainfathoni/rbagi.id.git $GITHUB/zainfathoni/rbagi.id
  cd $GITHUB/zainfathoni/rbagi.id
  yarn
fi

if [[ ! -d "$GITHUB/zainfathoni/s.imas.sg" ]] ; then
  git clone git@github.com:zainfathoni/s.imas.sg.git $GITHUB/zainfathoni/s.imas.sg
  cd $GITHUB/zainfathoni/s.imas.sg
  yarn
fi

if [[ ! -d "$GITLAB/kawalcovid19/website/kcov.id" ]] ; then
  git clone git@gitlab.com:kawalcovid19/website/kcov.id.git $GITLAB/kawalcovid19/website/kcov.id
  cd $GITLAB/kawalcovid19/website/kcov.id
  yarn
fi

if [[ ! -d "$GITHUB/frontend-id/s.feid.dev" ]] ; then
  git clone git@github.com:frontend-id/s.feid.dev.git $GITHUB/frontend-id/s.feid.dev
  cd $GITHUB/frontend-id/s.feid.dev
  yarn
fi

if [[ ! -d "$GITHUB/reactjs-id/shortlinks" ]] ; then
  git clone git@github.com:reactjs-id/shortlinks.git $GITHUB/reactjs-id/shortlinks
  cd $GITHUB/reactjs-id/shortlinks
  yarn
fi
