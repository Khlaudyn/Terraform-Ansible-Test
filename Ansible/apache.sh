!/bin/bash
sudo apt update -y
sudo apt install -y apache2
sudo apt install -y git

export META_INST_TYPE=`curl http://169.254.169.254/latest/meta-data/instance-type`
export META_INST_AZ=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone`
export META_INST_PUBLIC_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`


document='index.html'
cd /var/www/html
rm -r ${document}
echo "<!DOCTYPE html>" >> ${document}
echo "<html lang="en">" >> ${document}
echo "<head>" >> ${document}
echo "    <meta charset="UTF-8">" >> ${document}
echo "    <meta name="viewport" content="width=device-width, initial-scale=1.0">" >> ${document}

echo "    <title>WebServers</title>" >> ${document}
echo "<style>" >> ${document}
echo ".parent { align-items: center;  display:flex; justify-content: center; height: 100vh }" >> ${document}
echo ".parent1 { display:flex; justify-content: center; align-items:center;}" >> ${document}
echo ".parent2 { box-shadow: 5px 3px 10px #555; border:solid 1px #777; width: 80%; padding: 50px; }" >> ${document}

echo "</style>" >> ${document}
echo "</head>" >> ${document}
echo "<body>" >> ${document}
echo "    <div class="parent">" >> ${document}
echo "        <div class="parent1"> " >> ${document}
echo "            <div class="parent2">" >> ${document}

echo "                <div class="parent3">" >> ${document}

echo "                    <div class="child">" >> ${document}
echo "                        <div>INSTANCE TYPE</div>" >> ${document}
echo "                        <div>" $META_INST_TYPE "</div>" >> ${document}
echo "                    </div>" >> ${document}

echo "                    <div class="child">" >> ${document}
echo "                        <div>PUBLIC IP</div>" >> ${document}
echo "                        <div>" $META_INST_PUBLIC_IP "</div>" >> ${document}
echo "                    </div>" >> ${document}


echo "                    <div class="child">" >> ${document}
echo "                        <div>AVAILABILTY ZONE</div>" >> ${document}
echo "                        <div>" $META_INST_AZ "</div>" >> ${document}
echo "                    </div>" >> ${document}

echo "                </div>" >> ${document}
echo "            </div>" >> ${document}
echo "        </div>" >> ${document}
echo "      </div>" >> ${document}
echo "</body>" >> ${document}
echo "</html>" >> ${document}
sudo service apache2 start