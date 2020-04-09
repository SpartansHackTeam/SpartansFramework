# FULLPORTONLY MODE
if [[ "$MODE" = "vulnscan" ]]; then
  
  if [[ "$REPORT" = "1" ]]; then
    args="-t $TARGET"
    
    if [[ ! -z "$WORKSPACE" ]]; then
      args="$args -w $WORKSPACE"
      LOOT_DIR=$INSTALL_DIR/loot/workspace/$WORKSPACE
      echo -e "$OKBLUE[*]$RESET Saving loot to $LOOT_DIR [$RESET${OKGREEN}OK${RESET}$OKBLUE]$RESET"
      mkdir -p $LOOT_DIR 2> /dev/null
      mkdir $LOOT_DIR/domains 2> /dev/null
      mkdir $LOOT_DIR/screenshots 2> /dev/null
      mkdir $LOOT_DIR/nmap 2> /dev/null
      mkdir $LOOT_DIR/notes 2> /dev/null
      mkdir $LOOT_DIR/reports 2> /dev/null
      mkdir $LOOT_DIR/scans 2> /dev/null
      mkdir $LOOT_DIR/output 2> /dev/null
    fi

    args="$args --noreport -m vulnscan" 
    echo "$TARGET $MODE `date +"%Y-%m-%d %H:%M"`" 2> /dev/null >> $LOOT_DIR/scans/tasks.txt 2> /dev/null
    echo "spartansframework -t $TARGET -m $MODE --noreport $args" >> $LOOT_DIR/scans/$TARGET-vulnscan.txt
    echo "spartansframework -t $TARGET -m $MODE --noreport $args" >> $LOOT_DIR/scans/running-$TARGET-vulnscan.txt
    spartansframework $args | tee $LOOT_DIR/output/spartansframework-$TARGET-$MODE-`date +"%Y%m%d%H%M"`.txt 2>&1
    exit
  fi

  logo
  
  if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" "[spartansht.online] •?((¯°·._.• Started spartansframework scan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•"
  fi
  
  echo "$TARGET" >> $LOOT_DIR/domains/targets.txt

  if [[ "$OPENVAS" = "1" ]]; then
    sudo openvas-start 2> /dev/null > /dev/null
    echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
    echo -e "$OKRED RUNNING OPENVAS VULNERABILITY SCAN $RESET"
    echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
    echo "Scanning target: $TARGET "
    echo ""
    echo "-----------------------------------------------"
    echo "Listing OpenVAS version..."
    echo "-----------------------------------------------"
    omp -h $OPENVAS_HOST -p $OPENVAS_PORT -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD -O
    echo ""
    echo "Listing OpenVAS targets..."
    echo "-----------------------------------------------"
    omp -h $OPENVAS_HOST -p $OPENVAS_PORT -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD -T
    echo ""
    echo "Listing OpenVAS tasks..."
    echo "-----------------------------------------------"
    omp -h $OPENVAS_HOST -p $OPENVAS_PORT -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD -G
    echo ""
    echo "Creating scan task..."
    echo "-----------------------------------------------"
    ASSET_ID=$(omp -h $OPENVAS_HOST -p $OPENVAS_PORT -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD --xml="<create_target><name>$TARGET</name><hosts>$TARGET</hosts></create_target>" | xmlstarlet sel -t -v /create_target_response/@id) && echo "ASSET_ID: $ASSET_ID"
    if [[ "$ASSET_ID" == "" ]]; then
      ASSET_ID_ERROR=$(omp -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD --xml="<create_target><name>$TARGET</name><hosts>$TARGET</hosts></create_target>")
      if [[ "$ASSET_ID_ERROR" == *"Target exists already"* ]]; then
        ASSET_ID=$(omp -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD -T | grep " $TARGET" | awk '{print $1}')
        echo "ASSET_ID: $ASSET_ID"
      fi
    fi
    TASK_ID=$(omp -h $OPENVAS_HOST -p $OPENVAS_PORT -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD --xml "<create_task><name>$TARGET</name><preferences><preference><scanner_name>source_iface</scanner_name><value>eth0</value></preference></preferences><config id=\"74db13d6-7489-11df-91b9-002264764cea\"/><target id=\"$ASSET_ID\"/></create_task>" | xmlstarlet sel -t -v /create_task_response/@id) && echo "TASK_ID: $TASK_ID"
    if [[ "TASK_ID" == "" ]]; then
      omp -h $OPENVAS_HOST -p $OPENVAS_PORT -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD --xml "<create_task><name>$TARGET</name><preferences><preference><scanner_name>source_iface</scanner_name><value>eth0</value></preference></preferences><config id=\"74db13d6-7489-11df-91b9-002264764cea\"/><target id=\"$ASSET_ID\"/></create_task>"
    fi
    REPORT_ID=$(omp -h $OPENVAS_HOST -p $OPENVAS_PORT -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD --xml "<start_task task_id=\"$TASK_ID\"/>" | cut -d\> -f3 | cut -d\< -f1) && echo "REPORT_ID: $REPORT_ID"
    if [[ "$REPORT_ID" == "" ]]; then
      omp -h $OPENVAS_HOST -p $OPENVAS_PORT -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD --xml "<start_task task_id=\"$TASK_ID\"/>"
    fi
    echo ""
    resp=""
    while [[ $resp != "Done" && $REPORT_ID != "" ]]
    do
      omp -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD -G | grep $TASK_ID
      resp=$(omp -h $OPENVAS_HOST -p $OPENVAS_PORT -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD -G | grep "$TASK_ID" | awk '{print $2}')
      sleep 60
    done
    if [[ $REPORT_ID != "" ]]; then
      omp -h $OPENVAS_HOST -p $OPENVAS_PORT -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD --xml "<get_reports report_id=\"$REPORT_ID\" format_id=\"6c248850-1f62-11e1-b082-406186ea4fc5\"/>" | cut -d\> -f3 | cut -d\< -f1 | base64 -d > "$LOOT_DIR/output/openvas-$TARGET.html"

      echo "Report saved to $LOOT_DIR/output/openvas-$TARGET.html"
      cat $LOOT_DIR/output/openvas-$TARGET.html 2> /dev/null
    else
      echo "No report ID found. Listing scan tasks:"
      omp -h $OPENVAS_HOST -p $OPENVAS_PORT -u $OPENVAS_USERNAME -w $OPENVAS_PASSWORD -G | grep $TARGET
    fi
  fi
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
  echo -e "$OKRED DONE $RESET"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
  echo "$TARGET" >> $LOOT_DIR/scans/updated.txt
  mv $LOOT_DIR/scans/running-$TARGET-vulnscan.txt $LOOT_DIR/scans/finished-$TARGET-vulnscan.txt 2> /dev/null
  if [[ "$SLACK_NOTIFICATIONS_NMAP" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" postfile "$LOOT_DIR/nmap/nmap-$TARGET.txt"
    /bin/bash "$INSTALL_DIR/bin/slack.sh" postfile "$LOOT_DIR/nmap/nmap-$TARGET-udp.txt"
  fi
  if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" "[spartansht.online] •?((¯°·._.• Finished spartansframework scan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•"
  fi
  loot
  exit
fi

