-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Sep 08, 2026 at 10:23 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `DataAnalysis`
--

-- --------------------------------------------------------

--
-- Table structure for table `activity`
--

CREATE TABLE `activity` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `activity`
--

INSERT INTO `activity` (`id`, `user_id`, `action`, `description`, `entity_type`, `entity_id`, `created_at`) VALUES
(1, 1, 'rename_copy', 'Renamed dataset copy \"bloodpressurecopyv1\" to \"gggg\"', NULL, NULL, '2026-08-27 18:24:49'),
(2, 1, 'model_renamed', 'Renamed model from \'linear regression\' to \'gggg\'', 'model', 7, '2026-08-27 18:27:18'),
(3, 1, 'delete_dataset', 'Deleted dataset \"blood_pressure (1).csv\"', NULL, NULL, '2026-08-27 18:28:06'),
(4, 1, 'delete_dataset', 'Deleted dataset \"dataset .csv\"', NULL, NULL, '2026-08-27 18:45:01'),
(5, 1, 'model_renamed', 'Renamed model from \'Unnamed Model\' to \'ARSENAL MODEL\'', 'model', 8, '2026-08-29 18:11:37'),
(6, 1, 'model_renamed', 'Renamed model from \'Unnamed Model\' to \'Fraud transaction detector\'', 'model', 9, '2026-08-30 06:54:49');

-- --------------------------------------------------------

--
-- Table structure for table `api_keys`
--

CREATE TABLE `api_keys` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `key` varchar(255) NOT NULL,
  `name` varchar(100) DEFAULT 'Default AI Key',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dataframe_copies`
--

CREATE TABLE `dataframe_copies` (
  `id` int(11) NOT NULL,
  `owner_dataframe_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  `file_path` varchar(255) NOT NULL,
  `row_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('active','deleted') NOT NULL DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dataframe_copies`
--

INSERT INTO `dataframe_copies` (`id`, `owner_dataframe_id`, `user_id`, `name`, `updated_name`, `file_path`, `row_count`, `created_at`, `status`) VALUES
(1, 3, NULL, 'sample', NULL, 'datasets/3/copies/sample.json', 1460, '2026-07-27 11:26:08', 'active'),
(2, 4, NULL, 'titaniccopy', NULL, 'datasets/4/copies/titaniccopy.json', 891, '2026-07-27 12:02:08', 'active'),
(3, 5, NULL, 'mysample', NULL, 'datasets/5/copies/mysample.json', 891, '2026-07-27 12:14:06', 'active'),
(4, 7, 1, 'datasetcopy', NULL, 'datasets/7/copies/datasetcopy.json', 9117, '2026-07-27 13:27:25', 'active'),
(5, 6, 1, 'bloodPressurecopy', 'gggg', 'datasets/6/copies/bloodPressurecopy.json', 224, '2026-07-27 17:24:05', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `datasets`
--

CREATE TABLE `datasets` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `original_name` varchar(255) NOT NULL,
  `updated_name` varchar(255) DEFAULT NULL,
  `stored_name` varchar(255) NOT NULL,
  `file_type` varchar(20) NOT NULL,
  `file_size` bigint(20) DEFAULT 0,
  `file_path` varchar(255) NOT NULL,
  `row_count` int(11) DEFAULT 0,
  `column_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('active','deleted') NOT NULL DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `datasets`
--

INSERT INTO `datasets` (`id`, `user_id`, `original_name`, `updated_name`, `stored_name`, `file_type`, `file_size`, `file_path`, `row_count`, `column_count`, `created_at`, `status`) VALUES
(1, NULL, 'blood_pressure.csv', NULL, 'e2064bd8-d4dc-476e-b5ee-18d2b5448507.csv', 'csv', 6413, 'datasets/e2064bd8-d4dc-476e-b5ee-18d2b5448507.csv', 224, 7, '2026-07-27 10:37:11', 'active'),
(2, NULL, 'blood_pressure.csv', NULL, '247fcd91-a4c4-498d-a156-be3f55ea7668.csv', 'csv', 6413, 'datasets/247fcd91-a4c4-498d-a156-be3f55ea7668.csv', 224, 7, '2026-07-27 10:57:44', 'active'),
(3, NULL, 'ames.csv', NULL, '68c3588a-204f-44d3-a7af-099caecc397a.csv', 'csv', 460676, 'datasets/68c3588a-204f-44d3-a7af-099caecc397a.csv', 1460, 81, '2026-07-27 11:24:39', 'active'),
(4, NULL, 'titanic.csv', NULL, '96a771fb-4c7d-4fa4-b645-8cf6c4808998.csv', 'csv', 66349, 'datasets/96a771fb-4c7d-4fa4-b645-8cf6c4808998.csv', 891, 13, '2026-07-27 12:01:47', 'active'),
(5, NULL, 'titanic.csv', NULL, '5dd29a84-b699-46d0-977f-799e6a4e069d.csv', 'csv', 66349, 'datasets/5dd29a84-b699-46d0-977f-799e6a4e069d.csv', 891, 13, '2026-07-27 12:13:49', 'active'),
(6, 1, 'blood_pressure.csv', NULL, '5c83fd40-fab0-4dce-b81e-1776e94f87c0.csv', 'csv', 6413, 'datasets/5c83fd40-fab0-4dce-b81e-1776e94f87c0.csv', 217, 7, '2026-07-27 13:07:16', 'active'),
(7, 1, 'dataset .csv', 'data_set .csv', 'c6205607-e954-4829-b6c9-da616a9b225a.csv', 'csv', 14320070, 'datasets/c6205607-e954-4829-b6c9-da616a9b225a.csv', 9117, 2, '2026-07-27 13:26:44', 'deleted'),
(8, 1, 'ames.csv', NULL, '5cbd969f-d116-40f6-bd9d-19d1dd8559d1.csv', 'csv', 460676, 'datasets/5cbd969f-d116-40f6-bd9d-19d1dd8559d1.csv', 1460, 81, '2026-07-27 14:16:45', 'deleted'),
(9, 1, 'ames (1).csv', NULL, '2add06ab-9d5f-4636-9519-ea6b810be49a.csv', 'csv', 679809, 'datasets/2add06ab-9d5f-4636-9519-ea6b810be49a.csv', 1460, 81, '2026-07-27 14:35:43', 'deleted'),
(10, 1, 'blood_pressure (1).csv', NULL, '2090092d-4a3c-440c-ad63-69c05c886241.csv', 'csv', 9391, 'datasets/2090092d-4a3c-440c-ad63-69c05c886241.csv', 223, 7, '2026-07-28 08:26:53', 'deleted'),
(11, 1, 'blood_pressure (1) (1).csv', NULL, '236ce642-c806-4b53-af96-bb0db768cac3.csv', 'csv', 9345, 'datasets/236ce642-c806-4b53-af96-bb0db768cac3.csv', 223, 7, '2026-07-28 08:30:13', 'deleted'),
(12, 1, 'blood_pressure (1) (1) (1).csv', NULL, 'ff6ed2df-d8af-4bde-a478-5f91a923fc3d.csv', 'csv', 9345, 'datasets/ff6ed2df-d8af-4bde-a478-5f91a923fc3d.csv', 220, 7, '2026-07-28 08:30:42', 'deleted'),
(13, 1, 'blood_pressure (1).csv', NULL, '720fb3ca-04c8-4099-ae58-fe18a6de1a5e.csv', 'csv', 9382, 'datasets/720fb3ca-04c8-4099-ae58-fe18a6de1a5e.csv', 222, 7, '2026-07-28 08:43:50', 'deleted'),
(14, NULL, 'blood_pressure.csv', NULL, '464682fe-64da-4c43-a93f-521112a9864f.csv', 'csv', 6413, 'datasets/464682fe-64da-4c43-a93f-521112a9864f.csv', 224, 7, '2026-07-28 11:25:13', 'active'),
(15, 1, 'dataset .csv', NULL, 'fd178e24-e780-489b-98ac-30103a04bb42.csv', 'csv', 14320070, 'datasets/fd178e24-e780-489b-98ac-30103a04bb42.csv', 8879, 2, '2026-08-13 07:54:11', 'deleted'),
(16, NULL, 'dataset .csv', NULL, 'd5a6e99d-8784-4479-b6fa-f2a72f695dc8.csv', 'csv', 14320070, 'datasets/d5a6e99d-8784-4479-b6fa-f2a72f695dc8.csv', 9117, 2, '2026-08-13 07:54:40', 'active'),
(17, NULL, 'blood_pressure (1).csv', NULL, '30ab938c-1afe-490f-bc71-4c78c3cfa897.csv', 'csv', 9382, 'datasets/30ab938c-1afe-490f-bc71-4c78c3cfa897.csv', 224, 7, '2026-08-13 07:55:36', 'active'),
(18, NULL, 'blood_pressure.csv', NULL, '20ffa875-9332-4d31-bbc1-370e60beb4ea.csv', 'csv', 6413, 'datasets/20ffa875-9332-4d31-bbc1-370e60beb4ea.csv', 224, 7, '2026-08-13 07:55:45', 'active'),
(19, NULL, 'blood_pressure.csv', NULL, 'ac5618a2-c301-4516-9802-5c02c670a8d8.csv', 'csv', 6413, 'datasets/ac5618a2-c301-4516-9802-5c02c670a8d8.csv', 224, 7, '2026-08-13 07:56:48', 'active'),
(20, NULL, 'titanic.csv', NULL, '75f2b5ac-775a-47a2-8a7f-8be3fab8321d.csv', 'csv', 66349, 'datasets/75f2b5ac-775a-47a2-8a7f-8be3fab8321d.csv', 891, 13, '2026-08-13 07:59:13', 'active'),
(21, 1, 'titanic.csv', 'Titanic v1', '95bf13bc-685b-48da-90bd-b1d1b1119bc8.csv', 'csv', 66349, 'datasets/95bf13bc-685b-48da-90bd-b1d1b1119bc8.csv', 891, 13, '2026-08-17 08:01:33', 'active'),
(22, NULL, 'blood_pressure (1).csv', NULL, 'f09ba7f2-d8a5-442c-9baf-1d48ac82446a.csv', 'csv', 9382, 'datasets/f09ba7f2-d8a5-442c-9baf-1d48ac82446a.csv', 224, 7, '2026-08-17 08:08:08', 'active'),
(23, 1, 'prem-arsenal.csv', NULL, 'c8de3060-2116-40d1-bb6e-f3e82a42407d.csv', 'csv', 6675, 'datasets/c8de3060-2116-40d1-bb6e-f3e82a42407d.csv', 114, 7, '2026-08-29 18:04:28', 'active'),
(24, 1, 'creditcard.csv', NULL, '9046cf85-9746-49b2-8d04-c408d140e028.csv', 'csv', 150828752, 'datasets/9046cf85-9746-49b2-8d04-c408d140e028.csv', 284807, 31, '2026-08-29 18:29:38', 'active'),
(25, 1, 'eurusd_hour.csv', NULL, '24b006f8-6bfe-49c6-9731-fbb0a3bf701e.csv', 'csv', 12115086, 'datasets/24b006f8-6bfe-49c6-9731-fbb0a3bf701e.csv', 93084, 12, '2026-09-07 09:50:28', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `saved_models`
--

CREATE TABLE `saved_models` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `model_type` varchar(100) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `target` varchar(100) NOT NULL,
  `features` text NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `metrics` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `saved_models`
--

INSERT INTO `saved_models` (`id`, `user_id`, `model_type`, `name`, `target`, `features`, `file_path`, `metrics`, `created_at`) VALUES
(1, 1, 'linear_regression', 'LINEAR REGRESSION - wc', 'wc', '[\"Age\", \"SBP\"]', 'saved_models/linear_regression_wc_f442fa44.pkl', '{\"file_path\": \"saved_models/linear_regression_wc.joblib\"}', '2026-08-17 12:07:34'),
(2, 1, 'logistic_regression', 'LOGISTIC REGRESSION - Survived', 'Survived', '[\"Age\", \"Fare\"]', 'saved_models/logistic_regression_Survived_2a2da4f5.pkl', '{\"file_path\": \"saved_models/logistic_regression_Survived.joblib\"}', '2026-08-17 12:12:19'),
(3, 1, 'linear_regression', 'LINEAR REGRESSION - wc', 'wc', '[\"Age\", \"SBP\"]', 'saved_models/linear_regression_wc_cd69f255.pkl', '{\"file_path\": \"saved_models/linear_regression_wc.joblib\"}', '2026-08-17 12:14:29'),
(4, 1, 'linear_regression', 'LINEAR REGRESSION - wc', 'wc', '[\"Age\", \"SBP\"]', 'saved_models/linear_regression_wc_3ecade16.pkl', '{\"file_path\": \"saved_models/linear_regression_wc.joblib\"}', '2026-08-17 12:22:38'),
(5, 1, 'linear_regression', 'LINEAR REGRESSION - bmi', 'bmi', '[\"Age\", \"SBP\"]', 'saved_models/linear_regression_bmi_ac6a8ebe.pkl', '{\"file_path\": \"saved_models/linear_regression_bmi.joblib\"}', '2026-08-17 12:31:51'),
(6, 1, 'logistic_regression', 'LOGISTIC REGRESSION - Survived', 'Survived', '[\"Age\", \"Fare\"]', 'saved_models/logistic_regression_Survived_86046f63.pkl', '{\"file_path\": \"saved_models/logistic_regression_Survived.joblib\"}', '2026-08-17 12:32:48'),
(7, 1, 'linear_regression', 'gggg', 'bmi', '[\"Age\", \"SBP\"]', 'saved_models/linear_regression_bmi_9012d099.pkl', '{\"file_path\": \"saved_models/linear_regression_bmi.joblib\"}', '2026-08-17 12:36:35'),
(8, 1, 'logistic_regression', 'ARSENAL MODEL', 'home-adv', '[\"points\"]', 'saved_models/logistic_regression_home-adv_5c522f73.pkl', '{\"file_path\": \"saved_models/logistic_regression_home-adv.joblib\"}', '2026-08-29 18:08:17'),
(9, 1, 'logistic_regression', 'Fraud transaction detector', 'Class', '[\"V27\", \"V28\", \"Amount\"]', 'saved_models/logistic_regression_Class_7e7244ad.pkl', '{\"file_path\": \"saved_models/logistic_regression_Class.joblib\"}', '2026-08-29 18:48:11');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `google_id` varchar(255) DEFAULT NULL,
  `username` varchar(100) NOT NULL,
  `is_premium` tinyint(1) NOT NULL DEFAULT 0,
  `verified` int(11) NOT NULL DEFAULT 0,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `theme` varchar(10) DEFAULT 'light',
  `verification_code` varchar(6) DEFAULT NULL,
  `verification_expiry` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `google_id`, `username`, `is_premium`, `verified`, `email`, `password`, `created_at`, `theme`, `verification_code`, `verification_expiry`) VALUES
(1, NULL, 'dancann', 1, 1, 'ngigidancan227@gmail.com', 'scrypt:32768:8:1$v1URZYXIYjs3kVFG$98a6c0feed524a1e136c042fb6870547aefff3a07c54d1694cc8f94f6499b7b7aceaa97e6f328aabf34cb30c5ff4810ccfeda720b9c281ebb66616cdc94e4078', '2026-07-27 12:53:33', 'dark', '404752', '2026-07-30 15:20:06'),
(2, NULL, 'kijarney', 0, 1, 'kijarney@gmail.com', 'scrypt:32768:8:1$x8Y0veXYvv7kvp4T$c94c01d3bbb869b568eba7cb81b05d976f0910081c50c6a8641fe65339b16fee4e9908740e4421b77a8bae3fa567bf921dcfa04db0b94da28e558659709ae426', '2026-08-28 17:30:06', 'light', '720298', '2026-08-28 20:45:06');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity`
--
ALTER TABLE `activity`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_activity_user_id` (`user_id`),
  ADD KEY `idx_activity_created_at` (`created_at`);

--
-- Indexes for table `api_keys`
--
ALTER TABLE `api_keys`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_ai_key` (`key`),
  ADD KEY `idx_ai_keys_user_id` (`user_id`),
  ADD KEY `idx_ai_keys_active` (`is_active`);

--
-- Indexes for table `dataframe_copies`
--
ALTER TABLE `dataframe_copies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `owner_dataframe_id` (`owner_dataframe_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `datasets`
--
ALTER TABLE `datasets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `saved_models`
--
ALTER TABLE `saved_models`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `google_id` (`google_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity`
--
ALTER TABLE `activity`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `api_keys`
--
ALTER TABLE `api_keys`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dataframe_copies`
--
ALTER TABLE `dataframe_copies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `datasets`
--
ALTER TABLE `datasets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `saved_models`
--
ALTER TABLE `saved_models`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity`
--
ALTER TABLE `activity`
  ADD CONSTRAINT `fk_activity_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `api_keys`
--
ALTER TABLE `api_keys`
  ADD CONSTRAINT `fk_ai_keys_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `dataframe_copies`
--
ALTER TABLE `dataframe_copies`
  ADD CONSTRAINT `dataframe_copies_ibfk_1` FOREIGN KEY (`owner_dataframe_id`) REFERENCES `datasets` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `dataframe_copies_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `datasets`
--
ALTER TABLE `datasets`
  ADD CONSTRAINT `datasets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `saved_models`
--
ALTER TABLE `saved_models`
  ADD CONSTRAINT `saved_models_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
