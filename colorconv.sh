#!/usr/bin/env bash

rgb2frgb() {
  IFS=' ' read -r -a rgb <<<"$1"
  unset IFS

  local r="${rgb[0]}"
  local g="${rgb[1]}"
  local b="${rgb[2]}"

  local fr="$(echo "$r" | awk '{print $1/255}')"
  local fg="$(echo "$g" | awk '{print $1/255}')"
  local fb="$(echo "$b" | awk '{print $1/255}')"

  echo "$fr $fg $fb"
}

frgb2rgb() {
  IFS=' ' read -r -a frgb <<<"$1"
  unset IFS

  local fr="${frgb[0]}"
  local fg="${frgb[1]}"
  local fb="${frgb[2]}"

  local r="$(echo "$fr" | awk '{printf "%.0f",$1*255}')"
  local g="$(echo "$fg" | awk '{printf "%.0f",$1*255}')"
  local b="$(echo "$fb" | awk '{printf "%.0f",$1*255}')"

  echo "$r $g $b"
}

hex2rgb() {
  local hex="$1"

  local r="$((16#${hex:1:2}))"
  local g="$((16#${hex:3:2}))"
  local b="$((16#${hex:5:2}))"

  echo "$r $g $b"
}

rgb2hex() {
  IFS=' ' read -r -a rgb <<<"$1"
  unset IFS

  local r="${rgb[0]}"
  local g="${rgb[1]}"
  local b="${rgb[2]}"

  local hex="#$(printf "%02X" $1)$(printf "%02X" $2)$(printf "%02X" $3)"

  echo "$hex"
}

rgb2hsl() {
  IFS=' ' read -r -a frgb <<<"$(rgb2frgb "$1")"
  unset IFS

  local min="${frgb[0]}"
  local max="${frgb[0]}"

  for i in "${frgb[@]}"; do
    [ $(echo "$i > $max" | bc) = 1 ] && max=$i
    [ $(echo "$i < $min" | bc) = 1 ] && min=$i
  done

  local l="$(echo "$min $max" | awk '{printf "%.0f",(($1+$2)/2)*100}')"
  local s="$(echo "$min $max $l" | awk '{if ($1 == $2) {print 0} else if ($3 <= 0.5) {printf "%.0f",((($2 - $1)/($2 + $1)) * 100)} else if ($3 > 0.5) {printf "%.0f",((($2 - $1)/(2 - $2 - $1)) * 100)}}')"
  local h="$(echo "$min $max ${frgb[0]} ${frgb[1]} ${frgb[2]}" | awk '{if ($2 == $3) {printf "%.0f",((($4 - $5)/($2 - $1)) * 60)} else if ($2 == $4) {printf "%.0f",(((2 - ($5 - $3))/($2 - $1)) * 60)} else if ($5 == $2) {printf "%.0f",(((4 + ($3 - $4))/($2 - $1)) * 60)}}')"

  echo "$h $s $l"
}

hsl2rgb() {
  IFS=' ' read -r -a hsl <<<"$1"
  unset IFS

  local h="${hsl[0]}"
  local s="${hsl[1]}"
  local l="${hsl[2]}"

  if [ "$s" -eq "0" ]; then # 0 Saturation, so Grayscale
    local v="$(echo "$l" | awk '{print ($1 / 100) * 255}')"
    local ret="$v $v $v"
  else
    local temp0="$(echo "$l" | awk '{if (($1 / 100) < 0.5) {print 1} else {print 0}}')" # Luminance Calculation
    if [ "$temp0" -eq "1" ]; then
      local temp1="$(echo "$l $s" | awk '{print (($1 / 100) * (1 + ($2 / 100)))}')"
    else
      local temp1="$(echo "$l $s" | awk '{print ((($1 / 100) + ($2 / 100)) - (($1 / 100) * ($2 / 100)))}')"
    fi

    local temp2="$(echo "$l $temp0" | awk '{print ((2 * ($1 / 100)) - $2)}')"

    local temp3="$(echo "$h" | awk '{print ($1 / 360)}')" # Hue Calculation

    local temp_r="$(echo "$temp3" | awk '{if (($1 + 0.333) > 1) {print $1 + 0.333 - 1} else if (($1 + 0.333) < 0) {print ($1 + 0.333 + 1)} else {print ($1 + 0.333)}}')"
    local temp_g="$temp3"
    local temp_b="$(echo "$temp3" | awk '{if (($1 - 0.333) > 1) {print $1 - 0.333 - 1} else if (($1 - 0.333) < 0) {print ($1 - 0.333 + 1)} else {print ($1 - 0.333)}}')"

    local r="$(echo "$temp_r $temp1 $temp2" | awk '{if ((6 * $1) < 1) {print ($3 + ($2 - $3) * 6 * $1)} else if ((2 * $1) < 1) {print $2} else if ((3 * $1) < 2) {print ($3 + ($2 - $3) * (0.666 - $1) * 6)}}' | awk '{printf "%.2f",$1}')"
    local g="$(echo "$temp_g $temp1 $temp2" | awk '{if ((6 * $1) < 1) {print ($3 + ($2 - $3) * 6 * $1)} else if ((2 * $1) < 1) {print $2} else if ((3 * $1) < 2) {print ($3 + ($2 - $3) * (0.666 - $1) * 6)}}' | awk '{printf "%.2f",$1}')"
    local b="$(echo "$temp_b $temp1 $temp2" | awk '{if ((6 * $1) < 1) {print ($3 + ($2 - $3) * 6 * $1)} else if ((2 * $1) < 1) {print $2} else if ((3 * $1) < 2) {print ($3 + ($2 - $3) * (0.666 - $1) * 6)}}' | awk '{printf "%.2f",$1}')"

    echo "$(frgb2rgb "$r $g $b")"
  fi
}

case $1 in
-h)
  printf "BASH COLOR CONVERTER\n"
  exit 1
  ;;

--help)
  printf "BASH COLOR CONVERTER\n"
  exit 1
  ;;
esac
