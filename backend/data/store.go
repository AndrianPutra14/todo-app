package data

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"time"
)

type Todo struct {
	ID        int       `json:"id"`
	Title     string    `json:"title"`
	Done      bool      `json:"done"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type Store struct {
	mu       sync.RWMutex
	todos    []Todo
	nextID   int
	dataFile string
}

func NewStore(dataDir string) (*Store, error) {
	os.MkdirAll(dataDir, 0755)
	s := &Store{
		dataFile: filepath.Join(dataDir, "todos.json"),
	}
	if err := s.load(); err != nil {
		return nil, fmt.Errorf("failed to load todos: %w", err)
	}
	return s, nil
}

func (s *Store) load() error {
	file, err := os.ReadFile(s.dataFile)
	if err != nil {
		if os.IsNotExist(err) {
			s.todos = []Todo{}
			s.nextID = 1
			return s.save()
		}
		return err
	}
	if err := json.Unmarshal(file, &s.todos); err != nil {
		s.todos = []Todo{}
		s.nextID = 1
		return nil
	}
	maxID := 0
	for _, t := range s.todos {
		if t.ID > maxID {
			maxID = t.ID
		}
	}
	s.nextID = maxID + 1
	return nil
}

func (s *Store) save() error {
	data, err := json.MarshalIndent(s.todos, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(s.dataFile, data, 0644)
}

func (s *Store) GetAll() []Todo {
	s.mu.RLock()
	defer s.mu.RUnlock()
	result := make([]Todo, len(s.todos))
	copy(result, s.todos)
	return result
}

func (s *Store) Create(title string) Todo {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now().UTC()
	todo := Todo{
		ID:        s.nextID,
		Title:     title,
		Done:      false,
		CreatedAt: now,
		UpdatedAt: now,
	}
	s.nextID++
	s.todos = append(s.todos, todo)
	s.save()
	return todo
}

func (s *Store) GetByID(id int) (*Todo, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	for i := range s.todos {
		if s.todos[i].ID == id {
			t := s.todos[i]
			return &t, nil
		}
	}
	return nil, fmt.Errorf("todo not found")
}

func (s *Store) Update(id int, title *string, done *bool) (*Todo, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for i := range s.todos {
		if s.todos[i].ID == id {
			if title != nil {
				s.todos[i].Title = *title
			}
			if done != nil {
				s.todos[i].Done = *done
			}
			s.todos[i].UpdatedAt = time.Now().UTC()
			s.save()
			t := s.todos[i]
			return &t, nil
		}
	}
	return nil, fmt.Errorf("todo not found")
}

func (s *Store) Delete(id int) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	for i := range s.todos {
		if s.todos[i].ID == id {
			s.todos = append(s.todos[:i], s.todos[i+1:]...)
			s.save()
			return nil
		}
	}
	return fmt.Errorf("todo not found")
}
