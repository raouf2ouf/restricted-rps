import { MigrationInterface, QueryRunner } from "typeorm";

export class Init1708274751865 implements MigrationInterface {
    name = 'Init1708274751865'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "match" ("tech_id" SERIAL NOT NULL, "createDateTime" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "lastChangedDateTime" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "id" character varying(200) NOT NULL, "chain" character varying(100) NOT NULL, "address" character varying(60) NOT NULL, "matchId" integer NOT NULL, "card" integer NOT NULL, "secret" character varying(100) NOT NULL, CONSTRAINT "PK_ac3c9cc7464bb78abe6d081e0ba" PRIMARY KEY ("tech_id", "id"))`);
        await queryRunner.query(`CREATE TABLE "history" ("tech_id" SERIAL NOT NULL, "createDateTime" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "lastChangedDateTime" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "chain" character varying(100) NOT NULL, "address" character varying(60) NOT NULL, "gameAddress" character varying(60) NOT NULL, "gameId" integer NOT NULL, "paidAmount" character varying NOT NULL, "rewards" character varying(100) NOT NULL, CONSTRAINT "PK_802da7f6064d1182f13826455b6" PRIMARY KEY ("tech_id", "chain", "address", "gameAddress", "gameId"))`);
        await queryRunner.query(`CREATE TYPE "public"."game_state_enum" AS ENUM('0', '1', '2', '3', '4', '5', '6')`);
        await queryRunner.query(`CREATE TABLE "game" ("tech_id" SERIAL NOT NULL, "createDateTime" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "lastChangedDateTime" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "id" integer NOT NULL, "chain" character varying(100) NOT NULL, "address" character varying(60) NOT NULL, "blockNumber" integer NOT NULL, "initialDeck" character varying(100) NOT NULL, "secret" character varying(100) NOT NULL, "shuffledDeck" character varying(100), "state" "public"."game_state_enum" NOT NULL DEFAULT '0', CONSTRAINT "PK_94f8baac8b7e951aac8f7fbaa95" PRIMARY KEY ("tech_id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_ca574561c6e58569a051999d40" ON "game" ("address") `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP INDEX "public"."IDX_ca574561c6e58569a051999d40"`);
        await queryRunner.query(`DROP TABLE "game"`);
        await queryRunner.query(`DROP TYPE "public"."game_state_enum"`);
        await queryRunner.query(`DROP TABLE "history"`);
        await queryRunner.query(`DROP TABLE "match"`);
    }

}
