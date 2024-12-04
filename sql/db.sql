CREATE TABLE `aura_codes` (
  `identifier` VARCHAR(120) NOT NULL,
  `code` VARCHAR(12) NOT NULL,
  `uses` INT(20) NOT NULL,
  `playtime` INT(20) NOT NULL,
  `usedcodes` LONGTEXT NOT NULL,
  `usedfriendcodes` LONGTEXT NOT NULL,
  `rewardstoclaim` LONGTEXT NOT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE `aura_createdcodes` (
  `code` VARCHAR(60) NOT NULL,
  `reward_data` LONGTEXT NOT NULL,
  `date_creation` datetime DEFAULT NULL,
  `date_deletion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `aura_createdcodes`
  ADD PRIMARY KEY (`code`)
;