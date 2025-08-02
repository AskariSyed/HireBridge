using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HireBridgeAPI.Migrations
{
    /// <inheritdoc />
    public partial class EstimatedinterviewDurationAdded : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "EstimatedInterviewDuration",
                table: "Companies",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EstimatedInterviewDuration",
                table: "Companies");
        }
    }
}
