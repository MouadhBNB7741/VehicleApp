/*
  Warnings:

  - Added the required column `businessName` to the `PartnerApplication` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE `PartnerApplication` ADD COLUMN `businessName` VARCHAR(191) NOT NULL;
