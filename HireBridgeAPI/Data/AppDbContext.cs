using Microsoft.EntityFrameworkCore;
using HireBridgeAPI.Models;

namespace HireBridgeAPI.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options) { }

        public DbSet<Company> Companies { get; set; }
        public DbSet<Room> Rooms { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Student> Students { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Room>()
                .HasIndex(r => r.RoomNumber)
                .IsUnique();

            modelBuilder.Entity<Company>()
                .HasOne(c => c.AssignedRoom)
                .WithOne(r => r.Company)
                .HasForeignKey<Company>(c => c.AssignedRoomId)
                .IsRequired(false)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Student>()
    .HasOne(s => s.User)
    .WithOne()
    .HasForeignKey<Student>(s => s.UserID);
            modelBuilder.Entity<Student>()
                .HasIndex(s => s.RegistrationNumber)
                .IsUnique();
            modelBuilder.Entity<Student>(entity =>
            {
                entity.HasKey(e => e.StudentID);
                entity.Property(e => e.StudentID).ValueGeneratedOnAdd();
            });
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.UserID);
                entity.Property(e => e.UserID).ValueGeneratedOnAdd();
            });


            base.OnModelCreating(modelBuilder);

        }



    }
}
