import { MigrationInterface, QueryRunner } from "typeorm";

export class Init1707828817174 implements MigrationInterface {
    name = 'Init1707828817174'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "history" ("tech_id" SERIAL NOT NULL, "createDateTime" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "lastChangedDateTime" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "id" integer NOT NULL, "chain" character varying(100) NOT NULL, "address" character varying(60) NOT NULL, "gameAddress" character varying(60) NOT NULL, "gameId" integer NOT NULL, "paidAmount" character varying NOT NULL, "rewards" character varying(100) NOT NULL, CONSTRAINT "PK_f2f06f69d009233e9d3d47068b3" PRIMARY KEY ("tech_id"))`);
        await queryRunner.query(`CREATE TYPE "public"."game_state_enum" AS ENUM('0', '1', '2')`);
        await queryRunner.query(`CREATE TABLE "game" ("tech_id" SERIAL NOT NULL, "createDateTime" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "lastChangedDateTime" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "id" integer NOT NULL, "chain" character varying(100) NOT NULL, "address" character varying(60) NOT NULL, "initialDeck" character varying(100) NOT NULL, "secret" character varying(100) NOT NULL, "shuffledDeck" character varying(100), "state" "public"."game_state_enum" NOT NULL DEFAULT '0', CONSTRAINT "PK_94f8baac8b7e951aac8f7fbaa95" PRIMARY KEY ("tech_id"))`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP TABLE "game"`);
        await queryRunner.query(`DROP TYPE "public"."game_state_enum"`);
        await queryRunner.query(`DROP TABLE "history"`);
    }

}
