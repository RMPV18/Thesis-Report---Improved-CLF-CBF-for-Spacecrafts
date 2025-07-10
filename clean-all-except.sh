#!/usr/bin/env bash

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# %% novathesis.cls
# %% NOVA thesis cleanup script
# %%
# %% This work is licensed under the
# %% The LaTeX project public license (LPPL), version 1.3c
# %% To view a copy of this license, visit
# %% https://www.latex-project.org/lppl/lppl-1-3c/
# %%
# %% AUTHOR @github:
# %%      - joaomlourenco
# %% Departamento de Informática (www.di.fct.unl.pt)
# %% Faculdade de Ciências e Tecnologia (www.fct.unl.pt)
# %% Universidade NOVA de Lisboa (www.unl.pt)
# %%
# %% BUGS and SUGGESTIONS: please submit an issue at the project web page
# %%      at: https://github.com/joaomlourenco/novathesis/
# %%
# %% HELP: please DO NOT SEND ME EMAILS about LaTeX or the NOVAthesis template
# %%       please ask for help at GitHub Discussions page at
# %%          https://github.com/joaomlourenco/novathesis/discussions
# %%      or at the NOVAthesis facebook group at
# %%          https://www.facebook.com/groups/novathesis

NTDIR=$(pwd)
CMD=$(basename $0)
DEBUG=false
REMOVE_ORIGINAL_FIGURES=false

function usage {
  echo "Usage: [-f] $CMD [-l lang1[,lang2,…]] university[/school]"
  echo "               -f => remove 'original' figures from Chapters/Figures."
  echo "                     NOTICE that the original example chapters will not"
  echo "                     compile anymore. It is rather safe to use this option"
  echo "                     once you have your own document and have no need for"
  echo "                     the original figures."
  echo "               -l => receives a list of languages to keep (separated by commas)…"
  echo "                     all the files pertaining to other languages are removed."
  echo "       university => remove all customization files"
  echo "                     except for those of the given 'university'."
  echo "university/school => remove all customization files"
  echo "                     except for those of the given 'university/school'."
  exit 2
}

args=`getopt dfl: $*`
# you should not use `getopt abo: "$@"` since that would parse
# the arguments differently from what the set command below does.
if [ $? -ne 0 ]; then
  usage
fi
set -- $args
# You cannot use the set command with a backquoted getopt directly,
# since the exit code from getopt would be shadowed by those of set,
# which is zero by definition.
while :; do
        case "$1" in
        # -a|-b)
        #         echo "flag $1 set"; sflags="${1#-}$sflags"
        #         shift
        #         ;;
        -d)
                DEBUG=true
                shift
                ;;
        -f)
                REMOVE_ORIGINAL_FIGURES=true
                shift
                ;;
        -l)
                larg="$2"
                shift; shift
                ;;
        --)
                shift; break
                ;;
        esac
done

if [ -z "$1" ]; then
  usage
fi

if $DEBUG; then
  function deb_echo {
    echo $@
  }
else
  function deb_echo {
    :
  }
fi

deb_echo "single-char flags: '$sflags'"
deb_echo "larg is '$larg'"
deb_echo REST="[$0] [$1] [$2]"

IFS=/ read -r -d '' UNIV SCHL REST < <(printf %s "$1")
deb_echo "UNIV=$UNIV"
deb_echo "SCHL=$SCHL"
deb_echo "REST=$REST"
deb_echo LANGS=$(for i in ${larg//,/$IFS}; do echo "$i"; done)

if [ -n "$REST" ]; then
  usage
fi

if [ ! -d "NOVAthesisFiles/Schools" ]; then
  echo "'NOVAthesisFiles/Schools' folder not found!  Are we in the right folder??"
  exit 3
fi

echo "Removing all Universities except '$UNIV'"
find NOVAthesisFiles/Schools -type d -depth 1 | grep -v -e "${UNIV}$" | xargs rm -rf
if [ -n "$SCHL" ]; then
  echo "Removing all Schools from '$UNIV' except '$SCHL'"
  find NOVAthesisFiles/Schools -type d -depth 2 | grep -v -e "${UNIV}/Images" -e "${SCHL}$" | xargs rm -rf
fi

echo "Removing unnecessary Config files"
find Config -name '9_*' | fgrep -v "9_${UNIV}_${SCHL}.tex" | fgrep -v "9_${UNIV}.tex" | xargs rm -f

if [ -z "$larg" ]; then
  echo "No languages will be removed!"
else
  LANGS=${larg//,/\\|}
  echo "Removing all languages except: $larg"
  find -E NOVAthesisFiles/Strings Chapters -depth 1 -regex ".*-...?\..*" | grep -v -e ".*-\($LANGS\).\?.\(ldf\|tex\)" |  xargs rm
fi

if "$REMOVE_ORIGINAL_FIGURES"; then
  FILES_TO_REMOVE="\
    Chapters/Figures/knitting.svg \
    Chapters/Figures/access_allowed.pdf \
    Chapters/Figures/overleaf.jpg \
    Chapters/Figures/snowman-bitmap.jpg \
    Chapters/Figures/knitting-bitmap.jpg \
    Chapters/Figures/Covers/1up/ipl-isel-msc-en.pdf \
    Chapters/Figures/Covers/1up/ips-ests-msc-en.pdf \
    Chapters/Figures/Covers/1up/nova-ensp-???-en.pdf \
    Chapters/Figures/Covers/1up/nova-fcsh-???-en.pdf \
    Chapters/Figures/Covers/1up/nova-fct-???-en.pdf \
    Chapters/Figures/Covers/1up/nova-ims-msc-*-en.pdf \
    Chapters/Figures/Covers/1up/nova-ims-phd-en.pdf \
    Chapters/Figures/Covers/1up/nova-itqb-*-*-en.pdf \
    Chapters/Figures/Covers/1up/other-esep-msc-en.pdf \
    Chapters/Figures/Covers/1up/ulht-deisi-???-en.pdf \
    Chapters/Figures/Covers/1up/ulisboa-fc-???-en.pdf \
    Chapters/Figures/Covers/1up/ulisboa-fmv-???-en.pdf \
    Chapters/Figures/Covers/1up/ulisboa-ist-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-ea-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-ec-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-ed-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-ee-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-eeg-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-elach-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-em-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-ep-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-ese-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-i3b-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-ics-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-ie-???-en.pdf \
    Chapters/Figures/Covers/1up/uminho-ilch-???-en.pdf \
    Chapters/Figures/Covers/2up/01-nova-fct.pdf \
    Chapters/Figures/Covers/2up/02-nova-fcsh.pdf \
    Chapters/Figures/Covers/2up/03-nova-ims.pdf \
    Chapters/Figures/Covers/2up/04-nova-ims.pdf \
    Chapters/Figures/Covers/2up/05-nova-ims.pdf \
    Chapters/Figures/Covers/2up/06-nova-ensp.pdf \
    Chapters/Figures/Covers/2up/07-nova-itqb.pdf \
    Chapters/Figures/Covers/2up/08-nova-itqb.pdf \
    Chapters/Figures/Covers/2up/09-ulisboa-ist.pdf \
    Chapters/Figures/Covers/2up/10-ulisboa-fc.pdf \
    Chapters/Figures/Covers/2up/11-ulisboa-fmv.pdf \
    Chapters/Figures/Covers/2up/12-uminho-ea.pdf \
    Chapters/Figures/Covers/2up/13-uminho-ec.pdf \
    Chapters/Figures/Covers/2up/14-uminho-ed.pdf \
    Chapters/Figures/Covers/2up/15-uminho-ee.pdf \
    Chapters/Figures/Covers/2up/16-uminho-eeg.pdf \
    Chapters/Figures/Covers/2up/17-uminho-em.pdf \
    Chapters/Figures/Covers/2up/18-uminho-ep.pdf \
    Chapters/Figures/Covers/2up/19-uminho-ese.pdf \
    Chapters/Figures/Covers/2up/20-uminho-ics.pdf \
    Chapters/Figures/Covers/2up/21-uminho-ie.pdf \
    Chapters/Figures/Covers/2up/22-uminho-elach.pdf \
    Chapters/Figures/Covers/2up/22-uminho-ilch.pdf \
    Chapters/Figures/Covers/2up/23-uminho-i3b.pdf \
    Chapters/Figures/Covers/1up-2/ipl-isel-msc-en.pdf \
    Chapters/Figures/Covers/1up-2/ips-ests-msc-en.pdf \
    Chapters/Figures/Covers/1up-2/nova-ensp-???-en.pdf \
    Chapters/Figures/Covers/1up-2/nova-fcsh-???-en.pdf \
    Chapters/Figures/Covers/1up-2/nova-fct-???-en.pdf \
    Chapters/Figures/Covers/1up-2/nova-ims-msc-???-en.pdf \
    Chapters/Figures/Covers/1up-2/nova-ims-???-en.pdf \
    Chapters/Figures/Covers/1up-2/nova-itqb-*-*-en.pdf \
    Chapters/Figures/Covers/1up-2/other-esep-msc-en.pdf \
    Chapters/Figures/Covers/1up-2/ulht-deisi-???-en.pdf \
    Chapters/Figures/Covers/1up-2/ulisboa-fc-???-en.pdf \
    Chapters/Figures/Covers/1up-2/ulisboa-fmv-???-en.pdf \
    Chapters/Figures/Covers/1up-2/ulisboa-ist-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-ea-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-ec-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-ed-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-ee-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-eeg-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-elach-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-em-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-ep-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-ese-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-i3b-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-ics-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-ie-???-en.pdf \
    Chapters/Figures/Covers/1up-2/uminho-ilch-???-en.pdf \
    Chapters/Figures/snowman-vectorial.pdf \
    Chapters/Figures/access_forbidden.pdf \
    Chapters/Figures/snowstorm.svg \
    Chapters/Figures/github.jpg \
    Chapters/Figures/github1-PNG.png \
    Chapters/Figures/knitting-vectorial.pdf \
    Chapters/Figures/world-es-zaragoza.pdf \
    Chapters/Figures/ESTSetubal-IPS.jpg \
    Chapters/Figures/dont_touch.pdf \
    Chapters/Figures/snowman.svg \
    Chapters/Figures/snowstorm-vectorial.pdf \
    Chapters/Figures/github1.jpg \
    Chapters/Figures/github1-ORIG.png \
    Chapters/Figures/world-nl-uva.pdf \
    Chapters/Figures/snowstorm-bitmap.jpg"
  HIDDEN_FILES_TO_REMOVE=$(find Chapters/Figures -type f -name '.*')
  DIRS_TO_REMOVE="Chapters/Figures/Covers/1up Chapters/Figures/Covers/2up  Chapters/Figures/Covers/1up-2 Chapters/Figures/Covers"
  rm -f $FILES_TO_REMOVE $HIDDEN_FILES_TO_REMOVE
  for i in $DIRS_TO_REMOVE; do [[ -d "$i" ]] && rmdir "$i"; done
fi

echo "Exiting successfully"
exit 0
