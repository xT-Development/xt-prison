
--- USE THE SQL YOU NEED FOR YOUR FRAMEWORK ---


-- QBCORE // QBOX
ALTER TABLE `players`
	ADD COLUMN `jailtime` INT(11) NOT NULL DEFAULT '0';



-- OXCORE
ALTER TABLE `characters`
	ADD COLUMN `jailtime` INT(11) NOT NULL DEFAULT '0';



-- NDCORE
ALTER TABLE `nd_characters`
	ADD COLUMN `jailtime` INT(11) NOT NULL DEFAULT '0';



-- ESX
ALTER TABLE `users`
	ADD COLUMN `jailtime` INT(11) NOT NULL DEFAULT '0';