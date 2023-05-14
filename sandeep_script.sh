# @category   Magento2.XX
# @package    RunMagentoComand
# @author Sandeep Gupta
# @email ersandeepgu@gmail.com
# @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)



#!/bin/bash

# Define colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
cyan=`tput setaf 6`
reset=`tput sgr0`

# Check if running as correct user
echo "${cyan}Running Command script by Sandeep.."
# if [ "$(whoami)" != "magento" ]; then
#     echo "${red}Script must be run as the magento user${reset}"
#     exit 1
# fi


# Enable Maintenance Mode
php -d memory_limit=-1  bin/magento  maintenance:enable
echo "${green}Maintenance Mode Enable!${reset}"

# Prompt user to select cache types to clear
echo "${red}Script must be run as the magento user${reset}"
echo "${cyan}Which caches would you like to clear?"
echo "1) Full-page cache"
echo "2) Config cache"
echo "3) Block cache"
echo "4) All caches"
read -p "Enter your choice [1-4]: " choice

case $choice in
    1)
        cache_type="full_page"
        ;;
    2)
        cache_type="config"
        ;;
    3)
        cache_type="block_html"
        ;;
    4)
        cache_type="all"
        ;;
    *)
        echo "${red}Invalid choice${reset}"
        exit 1
        ;;
esac

echo "${cyan}Running extension installation${reset}"
echo "${green}Installing your extension........${reset}"

# Check if Magento CLI is available
if [ ! -f bin/magento ]; then
    echo "${red}Magento CLI not found${reset}"
    exit 1
fi

# Run Magento commands
php -d memory_limit=-1 bin/magento se:up
echo "${green}Setup upgrade completed!${reset}"
echo "${red}Compilation started!${reset}"
php -d memory_limit=-1 bin/magento se:di:com
echo "${cyan}Compilation completed!${reset}"
echo "${green}Starting static-content deploy!${reset}"
php -d memory_limit=-1 bin/magento se:static-content:deploy -f
php -d memory_limit=-1 bin/magento maintenance:disable

# Clear selected cache types
if [ "$cache_type" == "all" ]; then
    php -d memory_limit=-1 bin/magento c:c
    echo "${cyan}All caches cleared successfully!${reset}"
elif [ "$cache_type" == "full_page" ]; then
    php -d memory_limit=-1 bin/magento c:f
    echo "${cyan}Full-page cache cleared successfully!${reset}"
elif [ "$cache_type" == "config" ]; then
    php -d memory_limit=-1 bin/magento c:c config
    echo "${cyan}Config cache cleared successfully!${reset}"
elif [ "$cache_type" == "block_html" ]; then
    php -d memory_limit=-1 bin/magento c:c block_html
    echo "${cyan}Block cache cleared successfully!${reset}"
fi

# Fix permissions
echo "${yellow}Rectifying permissions${reset}"
chmod -R 777 var/
chmod -R 777 generated/
chmod -R 777 pub/static/
echo "${green}Permissions rectified!${reset}"
echo "${red}ALL DONE!!!${reset}"
