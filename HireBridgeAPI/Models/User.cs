using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class User
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]  // This tells EF Core to treat as auto-increment identity
    public int UserID { get; set; }

    [Required]
    [MaxLength(50)]
    public string Username { get; set; }

    [Required]
    public string PasswordHash { get; set; }

    [Required]
    [MaxLength(20)]
    public string Role { get; set; }

    public bool FirstTimeLogin { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
