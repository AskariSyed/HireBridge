using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireBridgeAPI.Migrations
{
    /// <inheritdoc />
    public partial class OneToOneRoomCompany : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "AssignedRoomId",
                table: "Companies",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Companies_AssignedRoomId",
                table: "Companies",
                column: "AssignedRoomId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Companies_Rooms_AssignedRoomId",
                table: "Companies",
                column: "AssignedRoomId",
                principalTable: "Rooms",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Companies_Rooms_AssignedRoomId",
                table: "Companies");

            migrationBuilder.DropIndex(
                name: "IX_Companies_AssignedRoomId",
                table: "Companies");

            migrationBuilder.AlterColumn<int>(
                name: "AssignedRoomId",
                table: "Companies",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");
        }
    }
}
