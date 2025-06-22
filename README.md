```
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
```

```
sudo apt install git -y && git clone https://github.com/Vzupa/main.git && chmod u+x main/setup.sh && ./main/setup.sh
```

### Kali repo not found
[Source](https://superuser.com/questions/1644520/apt-get-update-issue-in-kali)
```
wget https://http.kali.org/kali/pool/main/k/kali-archive-keyring/kali-archive-keyring_2025.1_all.deb && sudo dpkg -i kali-archive-keyring_2025.1_all.deb && rm kali-archive-keyring_2025.1_all.deb
```

