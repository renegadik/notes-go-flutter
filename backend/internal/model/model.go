package model

import "time"

type User struct {
	ID        uint   `gorm:"primaryKey"`
	Username  string `gorm:"unique;not null"`
	Password  string `gorm:"not null"`
	CreatedAt time.Time
}

type Note struct {
	ID         uint   `gorm:"primaryKey"`
	Title      string `gorm:"type:text;not null"`
	Content    string `gorm:"type:text"`
	CreatedAt  time.Time
	UpdatedAt  time.Time
	UserID     uint
	IsPinned   bool   `gorm:"default:false"`
	IsArchived bool   `gorm:"default:false"`
	Tags       []Tag  `gorm:"many2many:note_tags;"`              // связь с таблицей Tags
	Color      string `gorm:"type:varchar(7);default:'#FFFFFF'"` // hex код
}

type Tag struct {
	ID   uint   `gorm:"primaryKey"`
	Name string `gorm:"unique;not null"` // название тега, уникальное
}
