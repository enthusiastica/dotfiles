# ============================================================================
# General config
# ============================================================================


# Start new terminals with tmux and add pywal color scheme
if ! { [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; } then
  # Prevent lose color scheme for new tmux sessions
  wal -R -e -q

  tmux
else
  # Add wal color schema to main terminal
  cat ~/.cache/wal/sequences
fi

# Custom programs path
source ~/Programs/.programsrc

# Zsh config
export ZSH=~/.oh-my-zsh
ZSH_THEME=custom
plugins=(git virtualenv shrink-path)
source $ZSH/oh-my-zsh.sh


# ============================================================================
# Tachyon Laser
# ============================================================================


bk() {
  # Change background and color schema, and run neo function
  # The color schema is setted using the selected background
  # 
  # Args:
  #   $1 (optional): wallpaper path
  # 
  # Without args:
  #   Select a random wallpaper
  sh change-background >> /dev/null $1
  clear
  neo
}

desc() {
  # Print the description of the Astronomic Picture of the Day
  cat ~/.config/wal/image-description.txt
}
desc # Run at start

fav() {
  # Set preferred color schema
  # Good themes:
  # - base16-materia
  # - sexy-gnometerm
  # - sexy-theme2
  wal -q --theme sexy-gnometerm
}

lolban() {
  # Print rainbow message with special ascii font
  # 
  # Args:
  #   $1: Message
  if [ ! -z "$1" ]; then
    # Cool fonts list:
    # ~/.local/share/figlet-fonts/3d.flf
    figlet $@ -f ~/.local/share/figlet-fonts/3d.flf | lolcat
  else
    echo Miss message
  fi
}

cow() {
  # Invoke a psychedelic cow that tells your fortune
  fortune | cowsay -w -f three-eyes | lolcat
}

neo() {
  # Run custom neofetch config

  # If Ctrl+C is pressed, we clear the screen
  trap clear INT

  neofetch

  # Return as success after press Ctrl+C
  return 0
}


# ============================================================================
# Productivity
# ============================================================================


# Alias for open the default UI editor
alias ed=code

open () {
  # Open link in default browser
  # 
  # Args:
  #   $1: Link
  if [ ! -z "$1" ]; then
    $BROWSER $1
  else
    echo Miss link
  fi
}

cud() {
  # Interact with the current datetime
  # You can change the datetime using UTC timezone passing, in the follow
  # order, year, month, days, hours and/or minutes.
  # All of these args are optional, and you can pass year without passing month
  # using the next format: "cud 2020", set the actual year to 2020, keeping all
  # other values.
  # Also, you can pass month ignoring year using asterisk (*). E.g. "cud * 12",
  # set the actual month to December, keeping all other values.
  # Other example: "cud * * * 15 12" set the time to UTC 3:12 p.m. maintaining
  # the actual year, month and day.
  # If not arguments passed, it's set the time to auto
  # 
  # Args:
  #   $1 (optional): Year
  #   $2 (optional): Month
  #   $3 (optional): Day
  #   $4 (optional): Hours
  #   $5 (optional): Minutes
  # 
  # Without Args:
  #   Set the time to auto
  if [ ! -z "$1" ]; then
    if [[ $(timedatectl show --value --property NTPSynchronized) == 'no' ]]; then
      timedatectl setq-ntp false
    fi

    local year month day hour minute

    if [[ $1 && "$1" != "*" ]]; then
      year=$1
    else
      year=$(date +%Y)
    fi

    if [[ $2 && "$2" != "*" ]]; then
      month=$2
    else
      month=$(date +%m)
    fi

    if [[ $3 && "$3" != "*" ]]; then
      day=$3
    else
      day=$(date +%d)
    fi

    if [[ $4 && "$4" != "*" ]]; then

      # Fix UTC differences

      local timezone diff
      timezone=$(date +%Z)

      # - Get the absolute value of the difference
      diff=$(echo $timezone | grep -Po '(?<=\+|-)[0-9]+')

      # - When it's positive
      if [[ $(echo $timezone | grep -Po '[+](?<=[0-9])*') ]]; then
        hour=$(($4 + $diff))

      # - When it's negative
      elif [[ $(echo $timezone | grep -Po '[-](?<=[0-9])*') ]]; then
        hour=$(($4 - $diff))

      # - Whatever
      else
        hour=$4
      fi

    else
      hour=$(date +%H)
    fi

    if [[ $5 && "$5" != "*" ]]; then
      minute=$5
    else
      minute=$(date +%M)
    fi

    echo BEFORE: $(date +"%Y-%m-%d %H:%M:%S")
    sudo date -s "$year-$month-$day $hour:$minute:$(date +%S)" >> /dev/null
    echo AFTER: $(date +"%Y-%m-%d %H:%M:%S")
  else
    timedatectl set-ntp true
    echo RESTORED: $(date +"%Y-%m-%d %H:%M:%S")
  fi
}

wgc() {
  # Clone git repository in the appropiated workspace
  # 
  # Args:
  #   $1: "h" | "j": Clone for Home or Job workspace
  #   $2: Repo
  if [ ! -z "$1" ]; then
    if [ ! -z "$2" ]; then
      case $1 in
        h)
          git -C ~/Workspace/Home clone $2
          ;;
        j)
          git -C ~/Workspace/Job clone $2
          ;;
        *)
          echo Bad workspace
          ;;
      esac
    else
      echo Miss Repo
    fi
  else
    echo Miss positional-only parameters. Workspace "( \"h\" | \"j\" )" and Repo
  fi
}

pk() {
  # Terminate all processes related to a port
  # 
  # Args:
  #   $1: Port
  if [ ! -z "$1" ]; then
    local processes
    processes=$(lsof -t -i:$1)
    if [ processes ]; then
      kill -9 processes
    fi
  else
    echo Miss port
  fi
}


# ============================================================================
# Servers
# ============================================================================


drs() {
  # Run Django server in localhost
  # 
  # Args:
  #   $1 (optional): Port
  if [ ! -z "$1" ]; then
    python manage.py runserver 127.0.0.1:$1
  else
    python manage.py runserver
  fi
}

hl() {
  # Run Heroku server in localhost
  # 
  # Args:
  #   $1 (optional) - Port
  if [ ! -z "$1" ]; then
    heroku local -p $1
  else
    heroku local
  fi
}

ds() {
  # Open Django extended shell
  # 
  # Args:
  #   $1 (optional): DB schema
  if [ ! -z "$1" ]; then
    python manage.py tenant_command shell_plus --print-sql --schema=$1
  else
    python manage.py shell_plus --print-sql
  fi
}

hrs() {
  # Open Django shell in a remote Heroku App
  # 
  # Args:
  #   $1: Heroku App
  #   $2 (optional): DB schema
  if [ ! -z "$1" ]; then
    if [ ! -z "$2" ]; then
      heroku run python manage.py tenant_command shell --schema=$2 -a $1
    else
      heroku run python manage.py shell -a $1
    fi
  else
    echo Miss positional-only parameters: Heroku App, Tenant (optional)
  fi
}

hrq() {
  # Run PostgreSQL CLI in a Heroku App
  # 
  # Args:
  #   $1: Heroku App
  if [ ! -z "$1" ]; then
    heroku pg:psql -a $1
  else
    echo Miss Heroku App
  fi
}


# ============================================================================
# Python
# ============================================================================


export PIPENV_VERBOSITY=-1
export WORKON_HOME=~/.Envs/Python
source ~/.local/bin/virtualenvwrapper.sh

pyc() {
  # Create Python environment
  # 
  # Args:
  #   $1: Python source
  #   $2: Env name
  if [ ! -z "$1" ]; then
    if [ ! -z "$2" ]; then
      mkvirtualenv --system-site-packages -p $1 $2
      pyd
    else
      echo Miss Env name
    fi
  else
    echo Miss positional-only parameters: Python source, Env name
  fi
}

pya() {
  # Activate Python environment
  # 
  # Args:
  #   $1: Env name
  if [ ! -z "$1" ]; then
    source $WORKON_HOME/$1/bin/activate
  else
    echo Miss Env name
  fi
}

pyl() {
  # List all Python environments
  lsvirtualenv
}

pyr() {
  # Remove Python environment
  # 
  # Args:
  #   $1: Env name
  if [ ! -z "$1" ]; then
    rmvirtualenv $1
  else
    echo Miss Env name
  fi
}

pyd() {
  # Deactivate Python environment
  if [[ $(python -c 'import os; print(1 if os.getenv("VIRTUAL_ENV") else 0)') == "1" ]]; then
    deactivate
  fi
}


# ============================================================================
# Workspaces
# ============================================================================
# We use two workspaces for store repos, one for home works and other for the
# job works


WORKSPACE_HOME=~/Workspace/Home
WORKSPACE_JOB=~/Workspace/Job
source ~/Workspace/.homerc
source ~/Workspace/.jobrc

cleanworkspaces() {
  # Clean all workspaces
  # It's mean all virtual and variable environments setted by workspaces are
  # removed
  wh_cleanall
  wj_cleanall
}
